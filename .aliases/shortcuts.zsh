## Shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias code="codium"
alias cpr="rsync -ah --progress"
alias cls="clear"
alias d="cd ~/Downloads"
alias p="cd ~/git"
alias n="cd ~/Nas"
alias s="systemctl"
alias h="history"
alias j="journalctl -e"
alias jx="journalctl -xe"

# Safer rm, cp and mv
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# List all files colorized in long format
alias l="ls -lF ${colorflag}"
# List all files colorized in long format, including dot files
alias ll="ls -laF ${colorflag}"
# List only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"
# Always use color output for `ls`
alias ls="command ls ${colorflag}"

# Show week
alias week='date +%V'
# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"
alias list_chmod="stat -f '%A %N' "

# Docker
alias lzd="lazydocker"

