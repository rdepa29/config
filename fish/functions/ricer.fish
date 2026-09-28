function ricer
    set -l exe "$HOME/bin/ricer.exe"
    if test -f "$exe"
        "$exe" $argv
    else
        echo "ricer: missing $exe - run 'ricer install' once to install the shim"
        return 1
    end
end
