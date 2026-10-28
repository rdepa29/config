# fix unix paths for windows terminal
if status is-login; or status is-interactive
    contains /usr/bin $PATH; or set -gx PATH /usr/bin $PATH
    contains /bin $PATH; or set -gx PATH /bin $PATH
end

# ricer shims (and anything else dropped in ~/bin) on PATH
if status is-interactive
    test -d "$HOME/bin"; and fish_add_path "$HOME/bin"
end

# zoxide init
zoxide init fish | source

if status is-interactive
    source ~/.config/fish/conf.d/99-everforest.fish
end

# custom functions
alias c="clear"
alias f="fetch"
alias ff="fastfetch"
alias btop="btop"

function cf
    clear
    fetch
end

function cff
    clear
    fastfetch
end

function x -a path
    z "$path"
    ls
end

# java home (Temurin 17)
set -gx JAVA_HOME "C:\Users\Rdepa29\AppData\Local\Programs\Eclipse Adoptium\jdk-17.0.20.101-hotspot"
