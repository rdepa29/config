# Dynamic Material You-style accent theme
# Reads the Windows accent color from the registry on every interactive start.

if status is-interactive
    # DWM AccentColor is stored as 0xAABBGGRR
    set -l accent FF8C00
    set -l raw (env MSYS_NO_PATHCONV=1 reg.exe query "HKCU\Software\Microsoft\Windows\DWM" /v AccentColor 2>/dev/null | string match -r '0x[0-9a-fA-F]+' | string replace -r '^0x' '')
    if set -q raw[1]
        set -l hex (string sub -s 1 -l 8 $raw[1])
        # 0xAA BB GG RR -> RGB = RR GG BB
        set -l r (string sub -s 7 -l 2 $hex)
        set -l g (string sub -s 5 -l 2 $hex)
        set -l b (string sub -s 3 -l 2 $hex)
        set accent "$r$g$b"
    end

    # helpers: mix channel toward white
    function __accent_mix -a hex pct
        set -l d (math "0x$hex")
        set -l m (math "round($d + (255 - $d) * $pct)")
        printf '%02X' $m
    end

    function __accent_light -a hex pct
        string join '' (__accent_mix (string sub -s 1 -l 2 $hex) $pct) \
            (__accent_mix (string sub -s 3 -l 2 $hex) $pct) \
            (__accent_mix (string sub -s 5 -l 2 $hex) $pct)
    end

    # helper/accent vars
    set -g fish_color_accent       $accent

    # typed command-line text: keep fish defaults (command, operator, param, quote...)
    # accent only for UI chrome:
    set -g fish_color_selection    --background=$accent 000000
    set -g fish_color_search_match --background=$accent 000000
    set -g fish_pager_color_progress --background=$accent
    set -g fish_pager_color_selected_background --background=(__accent_light $accent 0.30)
end