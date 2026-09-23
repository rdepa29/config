function fish_prompt
    set -l last_status $status

    if test $last_status -eq 0
        set_color $fish_color_accent
    else
        set_color ff5f5f
    end

    echo -n ">< "

    set_color normal

    set_color b4b4b4
    echo -n (prompt_pwd)

    if test $last_status -eq 0
        set_color $fish_color_accent
    else
        set_color ff5f5f

        echo -n " {"$last_status"}"
    end

    echo -n " > "

    set_color normal
end
