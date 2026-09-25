# Dynamic accent theme - Windows accent color drives the fish palette.
# Reads via PowerShell (reg.exe misbehaves under MSYS fish), re-checks at most
# every 5s while a prompt is up, reapplies only when the accent actually changed.

if status is-interactive
    # DWM AccentColor (decimal, stored ABGR) -> RGB hex
    set -l accent FF8C00
    set -l raw (powershell -NoProfile -NonInteractive -Command "[Convert]::ToString((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\DWM' -Name AccentColor -ErrorAction Stop).AccentColor, 16)" 2>/dev/null)
    if set -q raw[1]
        set -l hex (string sub -s 1 -l 8 $raw[1])
        set -l r (string sub -s 7 -l 2 $hex)
        set -l g (string sub -s 5 -l 2 $hex)
        set -l b (string sub -s 3 -l 2 $hex)
        set accent "$r$g$b"
    end

    # helpers: mix a channel toward white (light) or black (dark)
    function __accent_mix -a hex pct
        set -l d (math "0x$hex")
        set -l m (math "round($d + (255 - $d) * $pct)")
        printf '%02X' $m
    end

    function __accent_light -a hex pct
        string join '' (__accent_mix (string sub -s 1 -l 2 $hex) $pct) (__accent_mix (string sub -s 3 -l 2 $hex) $pct) (__accent_mix (string sub -s 5 -l 2 $hex) $pct)
    end

    function __accent_dark_mix -a hex pct
        set -l d (math "0x$hex")
        set -l m (math "round($d * (1 - $pct))")
        printf '%02X' $m
    end

    function __accent_dark -a hex pct
        string join '' (__accent_dark_mix (string sub -s 1 -l 2 $hex) $pct) (__accent_dark_mix (string sub -s 3 -l 2 $hex) $pct) (__accent_dark_mix (string sub -s 5 -l 2 $hex) $pct)
    end

    function __accent_apply -a accent
        set -g fish_color_accent $accent
        set -g fish_color_command (__accent_light $accent 0.15)
        set -g fish_color_param (__accent_light $accent 0.50)
        set -g fish_color_option (__accent_light $accent 0.35)
        set -g fish_color_operator (__accent_light $accent 0.25)
        set -g fish_color_redirect (__accent_light $accent 0.25)
        set -g fish_color_quote (__accent_light $accent 0.65)
        set -g fish_color_comment (__accent_dark $accent 0.55)
        set -g fish_color_autosuggestion (__accent_dark $accent 0.30)
        set -g fish_color_cwd $accent
        set -g fish_color_selection --background=$accent 000000
        set -g fish_color_search_match --background=$accent 000000
        set -g fish_pager_color_progress --background=$accent
        set -g fish_pager_color_selected_background --background=(__accent_light $accent 0.30)
        set -g fish_pager_color_selected_description $accent
        set -g fish_pager_color_description (__accent_light $accent 0.35)
    end

    __accent_apply $accent

    # listener: re-read the accent as long as a prompt is up, throttled to 5s
    set -g __last_accent "$accent"
    set -g __accent_last_check 0
    function __accent_reload --on-event fish_prompt
        set -l now (date +%s)
        if test (math "$now - $__accent_last_check") -lt 5
            return
        end
        set -g __accent_last_check $now
        set -l raw (powershell -NoProfile -NonInteractive -Command "[Convert]::ToString((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\DWM' -Name AccentColor -ErrorAction Stop).AccentColor, 16)" 2>/dev/null)
        if set -q raw[1]
            set -l hex (string sub -s 1 -l 8 $raw[1])
            set -l r (string sub -s 7 -l 2 $hex)
            set -l g (string sub -s 5 -l 2 $hex)
            set -l b (string sub -s 3 -l 2 $hex)
            set -l accent "$r$g$b"
            if test "$accent" != "$__last_accent"
                set -g __last_accent $accent
                __accent_apply $accent
            end
        end
    end
end