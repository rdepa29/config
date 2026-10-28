function __fish_prompt_path
    set -l p $PWD
    set -l home (cygpath -u -- $HOME 2>/dev/null)
    test -z "$home"; and set home $HOME
    set -l msysroot (cygpath -u / 2>/dev/null)
    test -z "$msysroot"; and set msysroot /
    set -l msyswin (cygpath -m / 2>/dev/null)
    if test -n "$msyswin"
        set msyswin (string replace -r '^([A-Za-z]):' '/$1' -- $msyswin)
        set msyswin (string lower -- $msyswin)
        set msyswin (string trim -r -c / -- $msyswin)
    end

    if string match -rq '^[a-zA-Z]:' -- $p
        set p (cygpath -u -- $p 2>/dev/null)
    end

    if test "$p" = "$home"
        echo "~"
        return
    end

    if string match -q -- "$home/*" $p
        echo (string replace -- "$home" "~" $p)
        return
    end

    if test "$p" = "$msyswin" -o "$p" = "$msyswin/"
        echo "/"
        return
    end

    if test -n "$msyswin"; and test "$msyswin" != "/"; and string match -q -- "$msyswin/*" $p
        echo (string replace -- "$msyswin" "" $p)
        return
    end

    if test "$p" = "/" -o "$p" = "$msysroot"
        echo "/"
        return
    end

    if string match -rq '^/[a-zA-Z](/|$)' -- $p
        set -l rest (string sub -s 3 -- $p)
        if test -z "$rest"
            echo "/"
        else
            echo $rest
        end
        return
    end

    echo $p
end

function fish_prompt
    set -l last_status $status

    if test $last_status -eq 0
        set_color $fish_color_accent
    else
        set_color FFB8B8
    end

    echo -n ">< "

    set_color normal

    set_color B9CDB0
    echo -n (__fish_prompt_path)

    if test $last_status -eq 0
        set_color $fish_color_accent
    else
        set_color FFB8B8

        echo -n " {"$last_status"}"
    end

    echo -n " > "

    set_color normal
end
