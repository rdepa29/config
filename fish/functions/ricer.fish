function ricer
    set -l script "$HOME/bin/ricer.ps1"
    if test -f "$script"
        powershell -NoProfile -ExecutionPolicy Bypass -File "$script" $argv
    else
        echo "ricer: missing $script - run ricer.bat (or ricer install) once to install the shim"
        return 1
    end
end