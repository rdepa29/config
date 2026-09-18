# Fix missing UNIX paths when launching directly from Windows Terminal
if status is-login; or status is-interactive
    contains /usr/bin $PATH; or set -gx PATH /usr/bin $PATH
    contains /bin $PATH; or set -gx PATH /bin $PATH
end

# zoxide init
zoxide init fish | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# custom functions
alias c="clear"
alias ff="fastfetch"
alias btop="btop4win"

function cf
    clear
    fastfetch
end
