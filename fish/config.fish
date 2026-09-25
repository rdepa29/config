# # fix unix paths for windows terminal
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
    # Commands to run in interactive sessions can go here
end

# custom functions
alias c="clear"
alias ff="fastfetch"
alias btop="btop"

function cf
    clear
    fastfetch
end
