# Applies the current Windows accent color to:
#   - komorebi active borders (komorebi.json + reload)
#   - (fish reads the accent dynamically itself: ~/.config/fish/conf.d/99-accent.fish)
#   - (Windows Terminal accent scheme can be added here later)

$ErrorActionPreference = 'Stop'

function Get-AccentHex {
    $ui = New-Object Windows.UI.ViewManagement.UISettings
    $c = $ui.GetColorValue([Windows.UI.ViewManagement.UIColorType]::Accent)
    return ('{0:X2}{1:X2}{2:X2}' -f $c.R, $c.G, $c.B)
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