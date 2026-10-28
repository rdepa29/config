# Applies the current Windows accent color to:
#   - komorebi active borders (komorebi.json + reload)
#   - (fish reads the accent dynamically itself: ~/.config/fish/conf.d/99-accent.fish)
#   - (Windows Terminal accent scheme can be added here later)

$ErrorActionPreference = 'Stop'

function Get-AccentHex {
    $raw = [Convert]::ToString((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\DWM' -Name AccentColor -ErrorAction Stop).AccentColor, 16).PadLeft(8, '0')
    $r = [Convert]::ToInt32($raw.Substring(6, 2), 16)
    $g = [Convert]::ToInt32($raw.Substring(4, 2), 16)
    $b = [Convert]::ToInt32($raw.Substring(2, 2), 16)
    return ('{0:X2}{1:X2}{2:X2}' -f $r, $g, $b)
}

function Mix-White([string]$hex, [int]$pct) {
    $n = [Convert]::ToInt32($hex, 16)
    $r = ($n -shr 16) -band 0xFF; $g = ($n -shr 8) -band 0xFF; $b = $n -band 0xFF
    $mr = [int][math]::Round($r + (255 - $r) * $pct / 100)
    $mg = [int][math]::Round($g + (255 - $g) * $pct / 100)
    $mb = [int][math]::Round($b + (255 - $b) * $pct / 100)
    return ('{0:X2}{1:X2}{2:X2}' -f $mr, $mg, $mb)
}

try {
    $accent = Get-AccentHex
} catch {
    $accent = 'FF8C00'
}

$stack   = Mix-White $accent 25
$monocle = Mix-White $accent 45
$unfocused = '11111B'

Write-Output "accent:  #$accent"
Write-Output "stack:   #$stack"
Write-Output "monocle: #$monocle"

# --- komorebi.json ---
$komo = "$env:USERPROFILE\.config\komorebi\komorebi.json"
if (Test-Path -LiteralPath $komo) {
    $j = Get-Content -LiteralPath $komo -Raw | ConvertFrom-Json
    $j.border_colours.single   = "#$accent"
    $j.border_colours.stack    = "#$stack"
    $j.border_colours.monocle  = "#$monocle"
    $j.border_colours.unfocused = "#$unfocused"
    $j | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $komo -Encoding utf8
    komorebic reload-configuration 2>$null | Out-Null
    Write-Output "komorebi borders updated + reloaded"
}

# --- firefox material you accent ---
$accentCss = ":root {`n  --md-source: #$accent;`n}`n"
$ffDirs = @("$env:USERPROFILE\.config\firefox\chrome")
$ffDirs += Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory -ErrorAction SilentlyContinue |
    ForEach-Object { Join-Path $_.FullName 'chrome' } |
    Where-Object { Test-Path -LiteralPath $_ }

foreach ($dir in $ffDirs | Select-Object -Unique) {
    $file = Join-Path $dir 'accent.css'
    [System.IO.File]::WriteAllText($file, $accentCss, (New-Object System.Text.UTF8Encoding($false)))
    Write-Output "firefox accent updated: $file (restart firefox to apply)"
}