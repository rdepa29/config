function fish_right_prompt
    set_color b4b4b4

    if test $CMD_DURATION -lt 1000
        echo -n $CMD_DURATION"ms"
    else
        set -l total_seconds (math -s0 "$CMD_DURATION / 1000")

        if test $total_seconds -lt 60
            echo -n $total_seconds"s"
        else
            set -l minutes (math -s0 "$total_seconds / 60")
            set -l remainder_seconds (math "$total_seconds % 60")
            echo -n $minutes"m "$remainder_seconds"s"
        end
    end

    set_color normal
end
