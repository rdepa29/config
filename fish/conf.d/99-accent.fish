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

    # helpers: mix a channel toward white (light) or black (dark)
    function __accent_mix -a hex pct
        set -l d (math "0x$hex")
        set -l m (math "round($d + (255 - $d) * $pct)")
        printf '%02X' $m
    end

    function __accent_dim_mix -a hex pct
        set -l d (math "0x$hex")
        set -l m (math "round($d * (1 - $pct))")
        printf '%02X' $m
    end

    function __accent_light -a hex pct
        string join '' (__accent_mix (string sub -s 1 -l 2 $hex) $pct) (__accent_mix (string sub -s 3 -l 2 $hex) $pct) (__accent_mix (string sub -s 5 -l 2 $hex) $pct)
    end

    function __accent_dark -a hex pct
        string join '' (__accent_dim_mix (string sub -s 1 -l 2 $hex) $pct) (__accent_dim_mix (string sub -s 3 -l 2 $hex) $pct) (__accent_dim_mix (string sub -s 5 -l 2 $hex) $pct)
    end

    # listener: re-read the accent when Windows changes it
    function __accent_reload --on-event fish_prompt
        set -l raw (env MSYS_NO_PATHCONV=1 reg.exe query "HKCU\Software\Microsoft\Windows\DWM" /v AccentColor 2>/dev/null | string match -r '0x[0-9a-fA-F]+' | string replace -r '^0x' '')
        if set -q raw[1]
            set -l hex (string sub -s 1 -l 8 $raw[1])
            set -l r (string sub -s 7 -l 2 $hex)
            set -l g (string sub -s 5 -l 2 $hex)
            set -l b (string sub -s 3 -l 2 $hex)
            set -l accent "$r$g$b"
            if test "$accent" != "$__last_accent"
                set -g __last_accent $accent
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
        end
    end

    # initial state so the first prompt applies the accent
    set -g __last_accent ""
end