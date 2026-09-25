param(
    [string]$Command = 'help',
    [string[]]$Rest = @()
)

$ErrorActionPreference = 'Stop'

$RepoUrl   = if ($env:RICER_REPO) { $env:RICER_REPO } else { 'https://github.com/rdepa29/config' }
$RepoDir   = Join-Path $env:LOCALAPPDATA 'rdepa29-config'
$BinDir    = Join-Path $env:USERPROFILE 'bin'
$CfgRoot   = Join-Path $env:USERPROFILE '.config'
$ScoopDir  = Join-Path $env:USERPROFILE 'scoop'
$ScoopShim = Join-Path $ScoopDir 'shims'
$FishLauncher = 'C:\msys64\fish.cmd'
$WtGuid    = '{33D44DF6-71E9-46FE-AB19-316CCBB5C965}'
$Apps      = @('7zip','git','komorebi','whkd','autohotkey','micro','wezterm','zoxide','fastfetch','btop','JetBrainsMono-NF')
$CfgDirs   = @('accent-theme','cava','fish','komorebi','micro','wezterm','whkd')

function Write-Step([string]$m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok  ([string]$m) { Write-Host "    $m" -ForegroundColor Green }
function Write-Warn([string]$m) { Write-Host "    WARN: $m" -ForegroundColor Yellow }
function Write-Err ([string]$m) { Write-Host "    ERROR: $m" -ForegroundColor Red }

function Test-Cmd([string]$name) {
    try { $null = Get-Command $name -ErrorAction Stop; return $true } catch { return $false }
}

function Ensure-Scoop {
    if (Test-Path (Join-Path $ScoopShim 'scoop.cmd')) { return }
    Write-Step 'Installing Scoop'
    if (-not (Test-Cmd 'git')) { Write-Err "git not found. Install git from https://git-scm.com then re-run."; throw 'git required' }
    Invoke-Expression ((Invoke-WebRequest -UseBasicParsing 'https://get.scoop.sh').Content)
    if (-not (Test-Path (Join-Path $ScoopShim 'scoop.cmd'))) { throw 'Scoop install failed' }
    Write-Ok 'Scoop installed'
}

function Ensure-Buckets {
    Write-Step 'Adding Scoop buckets (extras, nerd-fonts)'
    & scoop bucket add extras       | Out-Null
    & scoop bucket add nerd-fonts   | Out-Null
    & scoop update > $null 2>&1
}

function Install-Apps {
    $targets = @()
    if ($Rest.Count -gt 0) {
        foreach ($p in $Rest) {
            $hit = $Apps | Where-Object { $_ -eq $p }
            if ($hit) { $targets += $hit }
        }
        if ($targets.Count -eq 0) { Write-Warn 'none of the given packages are managed by ricer'; return }
        Write-Step "Installing apps: $($targets -join ', ')"
        foreach ($app in $targets) { & scoop install $app }
    } else {
        Write-Step "Installing apps: $($Apps -join ', ')"
        foreach ($app in $Apps) { & scoop install $app }
        Write-Step 'Installing cava (best effort, manifest may be missing outside extra Scoop buckets)'
        & scoop install cava 2>&1 | Out-Null
    }
}

function Ensure-MsysAndFish {
    if (-not (Test-Path 'C:\msys64\usr\bin\bash.exe')) {
        Write-Step 'Installing MSYS2 via winget'
        if (-not (Test-Cmd 'winget')) { throw 'winget not available; install MSYS2 from https://www.msys2.org manually' }
        & winget install --id MSYS2.MSYS2 --silent --accept-package-agreements --accept-source-agreements
    }
    if (-not (Test-Path 'C:\msys64\usr\bin\bash.exe')) { Write-Err 'MSYS2 not found at C:\msys64'; return }
    Write-Step 'Installing fish via MSYS2 pacman'
    & 'C:\msys64\usr\bin\bash.exe' -lc 'pacman -Sy --noconfirm --needed fish'
    Write-Ok "fish installed ($( & 'C:\msys64\usr\bin\fish.exe' --version 2>&1))"
}

function Ensure-FishLauncher {
    if (Test-Path $FishLauncher) { return }
    Write-Step "Creating $FishLauncher"
    if (-not (Test-Path 'C:\msys64')) { New-Item -ItemType Directory -Path 'C:\msys64' -Force | Out-Null }
    Set-Content -LiteralPath $FishLauncher -Encoding ASCII @'
@echo off
set "HOME=%USERPROFILE%"
if not defined XDG_CONFIG_HOME set "XDG_CONFIG_HOME=%USERPROFILE%\.config"
set "PATH=C:\msys64\usr\bin;%PATH%"
C:\msys64\usr\bin\fish.exe %*
'@
    Write-Ok 'fish launcher created'
}

function Ensure-GitBashAlias {
    Write-Step 'Adding fish alias to git bash'
    $bashrc = Join-Path $env:USERPROFILE '.bashrc'
    if (-not (Test-Path $bashrc)) { Set-Content -LiteralPath $bashrc -Encoding ASCII '' }
    if (-not (Select-String -LiteralPath $bashrc -Pattern 'fish' -Quiet)) {
        Add-Content -LiteralPath $bashrc -Encoding ASCII "alias fish='/c/msys64/usr/bin/fish'"
    }
    $bp = Join-Path $env:USERPROFILE '.bash_profile'
    if (-not (Test-Path $bp)) {
        Set-Content -LiteralPath $bp -Encoding ASCII @'
# source bashrc for interactive login shells
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi
'@
    }
    Write-Ok 'git bash alias ready'
}

function Ensure-WTProfile {
    Write-Step 'Syncing Windows Terminal fish profile'
    $settings = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    if (-not (Test-Path -LiteralPath $settings)) { Write-Warn 'Windows Terminal settings.json not found'; return }
    $j = Get-Content -LiteralPath $settings -Raw | ConvertFrom-Json
    $guids = @($j.profiles.list | ForEach-Object { $_.guid })
    if ($guids -contains $WtGuid) { Write-Ok 'fish profile already present'; return }
    $p = [pscustomobject]@{
        commandline        = 'C:\msys64\fish.cmd'
        env                = [pscustomobject]@{ HOME = $env:USERPROFILE }
        guid               = $WtGuid
        hidden             = $false
        name               = 'fish'
        startingDirectory  = $env:USERPROFILE
    }
    $j.profiles.list += $p
    $j | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $settings -Encoding UTF8
    Write-Ok 'fish profile added'
}

function Ensure-Repo {
    if (-not (Test-Path (Join-Path $RepoDir '.git'))) {
        Write-Step "Cloning $RepoUrl -> $RepoDir"
        if (-not (Test-Cmd 'git')) { throw 'git not available' }
        & git clone --depth 1 $RepoUrl $RepoDir
        if ($LASTEXITCODE -ne 0) { throw 'git clone failed' }
    } else {
        Write-Step "Updating $RepoDir"
        & git -C $RepoDir pull --ff-only
    }
}

function Sync-Configs {
    Write-Step "Mirroring configs into $CfgRoot"
    foreach ($d in $CfgDirs) {
        $src = Join-Path $RepoDir $d
        if (Test-Path $src) {
            robocopy $src (Join-Path $CfgRoot $d) /E /NFL /NDL /NJH /NJS | Out-Null
        }
    }
    $scoopCfgDir = Join-Path $CfgRoot 'scoop'
    New-Item -ItemType Directory -Path $scoopCfgDir -Force | Out-Null
    if (Test-Path (Join-Path $RepoDir 'scoop\config.json')) {
        Copy-Item (Join-Path $RepoDir 'scoop\config.json') (Join-Path $scoopCfgDir 'config.json') -Force
    }
    $microApp = Join-Path $env:APPDATA 'micro'
    if (-not (Test-Path $microApp)) { robocopy (Join-Path $CfgRoot 'micro') $microApp /E /NFL /NDL /NJH /NJS | Out-Null }
    $cavaApp = Join-Path $env:APPDATA 'cava'
    if (-not (Test-Path $cavaApp)) { robocopy (Join-Path $CfgRoot 'cava') $cavaApp /E /NFL /NDL /NJH /NJS | Out-Null }
    Write-Ok 'configs synced'
}

function Ensure-BinShims {
    Write-Step "Installing ricer shims to $BinDir"
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
    $srcDir = Split-Path -Parent $PSCommandPath
    Copy-Item (Join-Path $srcDir 'ricer.ps1') (Join-Path $BinDir 'ricer.ps1') -Force
    Copy-Item (Join-Path $srcDir 'ricer.cmd') (Join-Path $BinDir 'ricer.cmd') -Force
    if (-not (Test-Path (Join-Path $BinDir 'fish.cmd'))) {
        Set-Content -LiteralPath (Join-Path $BinDir 'fish.cmd') -Value ('@echo off' + "`r`n" + 'call C:\msys64\fish.cmd %*') -Encoding ASCII
    }
    if (-not (Test-Path (Join-Path $BinDir 'bash.cmd'))) {
        Set-Content -LiteralPath (Join-Path $BinDir 'bash.cmd') -Value ('@echo off' + "`r`n" + 'C:\msys64\usr\bin\bash.exe %*') -Encoding ASCII
    }
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath -notmatch [regex]::Escape($BinDir)) {
        [Environment]::SetEnvironmentVariable('Path', $userPath.TrimEnd(';') + ';' + $BinDir, 'User')
        Write-Ok 'added to user PATH (new shells will see fish/bash/ricer)'
    } else {
        Write-Ok 'already on user PATH'
    }
}

function Ensure-Env {
    Write-Step 'Setting user environment variables'
    [Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', (Join-Path $CfgRoot 'wezterm\wezterm.lua'), 'User')
    [Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', $CfgRoot, 'User')
    Write-Ok 'env vars set'
}

function Invoke-Install {
    Ensure-Scoop
    $env:PATH = "$ScoopShim;$env:PATH"
    Ensure-Buckets
    Install-Apps
    Ensure-MsysAndFish
    Ensure-FishLauncher
    Ensure-GitBashAlias
    Ensure-WTProfile
    Ensure-Repo
    Sync-Configs
    Ensure-BinShims
    Ensure-Env
}

function Invoke-Update {
    if ($Rest.Count -gt 0) {
        Write-Step "Updating apps: $($Rest -join ', ')"
        foreach ($app in $Rest) { & scoop update $app }
        return
    }
    Write-Step 'Updating Scoop apps'
    & scoop update 2>&1 | Out-Null
    Ensure-MsysAndFish
    Ensure-Repo
    Sync-Configs
    Ensure-BinShims
    Ensure-FishLauncher
    Write-Ok 'ricer update complete'
}

function Invoke-Uninstall {
    if ($Rest.Count -eq 0) { Write-Err 'ricer uninstall <package...>'; return }
    foreach ($pkg in $Rest) {
        if ($pkg -eq 'fish') {
            Write-Step 'Removing MSYS2 fish'
            & 'C:\msys64\usr\bin\bash.exe' -lc 'pacman -Rn --noconfirm fish'
            Remove-Item -LiteralPath $FishLauncher -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath (Join-Path $BinDir 'fish.cmd') -Force -ErrorAction SilentlyContinue
            Write-Ok 'fish removed'
            continue
        }
        if ($pkg -eq 'ricer') {
            Write-Step 'Removing ricer shims'
            Remove-Item -LiteralPath (Join-Path $BinDir 'ricer.cmd') -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath (Join-Path $BinDir 'ricer.ps1') -Force -ErrorAction SilentlyContinue
            Write-Ok 'ricer shims removed (PATH entry left in place)'
            continue
        }
        if ($Apps -contains $pkg) {
            & scoop uninstall $pkg
            Write-Ok "$pkg uninstalled"
        } else {
            Write-Warn "$pkg is not a ricer-managed package"
        }
    }
}

function Invoke-List {
    Write-Step 'Installed Scoop apps'
    & scoop list
    Write-Step "Managed configs in $CfgRoot"
    foreach ($d in $CfgDirs) {
        $ok = Test-Path (Join-Path $CfgRoot $d)
        "{0,-4} {1}" -f ($(if ($ok) { 'OK' } else { '--' })), $d
    }
}

function Invoke-Status {
    Write-Step 'ricer health check'
    $checks = [ordered]@{
        'scoop'                 = Test-Path (Join-Path $ScoopShim 'scoop.cmd')
        'git (git for windows)' = Test-Cmd 'git'
        'MSYS2 bash'            = Test-Path 'C:\msys64\usr\bin\bash.exe'
        'fish'                  = Test-Path 'C:\msys64\usr\bin\fish.exe'
        'fish launcher'         = Test-Path $FishLauncher
        'configs synced'        = (Test-Path (Join-Path $CfgRoot 'fish')) -and (Test-Path (Join-Path $CfgRoot 'wezterm'))
        'bin shims'             = (Test-Path (Join-Path $BinDir 'ricer.cmd')) -and (Test-Path (Join-Path $BinDir 'fish.cmd')) -and (Test-Path (Join-Path $BinDir 'bash.cmd'))
        'repo clone'            = Test-Path (Join-Path $RepoDir '.git')
    }
    foreach ($k in $checks.Keys) {
        "{0,-5} {1}" -f ($(if ($checks[$k]) { 'PASS' } else { 'FAIL' })), $k
    }
    if ($checks['configs synced']) {
        $srcAccent = Join-Path $CfgRoot 'fish\conf.d\99-accent.fish'
        if (Test-Path $srcAccent) {
            if (Select-String -LiteralPath $srcAccent -Pattern '\\\r?$' -Quiet) {
                Write-Warn '99-accent.fish still has fish-4-incompatible line continuations'
            } else {
                Write-Ok '99-accent.fish parsed clean for fish 4.x'
            }
        }
    }
}

function Show-Help {
    @'
ricer - dotfiles package manager

USAGE
  ricer <command> [packages...]

COMMANDS
  install                full bootstrap (scoop, apps, msys2+fish, configs, WT profile, shims)
  install <pkg...>       install only those managed scoop apps
  update                 scoop update * + re-sync configs/shims from the repo
  update <pkg...>        scoop update <pkg...>
  uninstall <pkg...>     scoop uninstall; special: fish, ricer
  list                   installed apps + synced configs
  status                 health checks
  config                 re-clone + re-sync configs from the repo
  help                   this output

MANAGED APPS: 7zip git komorebi whkd autohotkey micro wezterm zoxide fastfetch btop JetBrainsMono-NF
CONFIGS:      accent-theme cava fish komorebi micro scoop/wezterm whkd (repo: https://github.com/rdepa29/config)
'@
}

function Invoke-Config {
    Ensure-Repo
    Sync-Configs
}

switch ($Command.ToLower()) {
    { $_ -in @('', 'help', '-h', '--help') } { Show-Help }
    'install'   { Invoke-Install }
    'update'    { Invoke-Update }
    'uninstall' { Invoke-Uninstall }
    'rm'        { Invoke-Uninstall }
    'list'      { Invoke-List }
    'ls'        { Invoke-List }
    'status'    { Invoke-Status }
    'doctor'    { Invoke-Status }
    'config'    { Invoke-Config }
    'cfg'       { Invoke-Config }
    default     { Write-Err "Unknown command: $Command"; Show-Help }
}