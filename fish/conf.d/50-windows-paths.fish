# Windows-style path handling for fish on MSYS2:
#  cd /  -> C:\, cd C:\Windows etc. accepted, prompt shows Windows paths
if status is-interactive
    function cd
        set -l argc (count $argv)
        if test $argc -eq 0
            builtin cd "$HOME"
            return $status
        else if test $argc -ne 1
            builtin cd $argv
            return $status
        end
        set -l target $argv[1]
        if test "$target" = "/"
            set target /c
        else if string match -r -q '^[a-zA-Z]:[\\\\/]$' -- $target
            set target /c
        else if string match -r -q '^[a-zA-Z]:' -- $target
            set target (cygpath -u -- $target)
        end
        builtin cd $target
    end

    function fish_prompt
        set -l win (cygpath -w -- $PWD 2>/dev/null)
        printf '%s> ' $win
    end
end