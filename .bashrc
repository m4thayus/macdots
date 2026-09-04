#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi

$(toys system bash-completion install)

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi

source ~/.bash_aliases
