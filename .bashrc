#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi
shopt -s checkwinsize

alias be="bundle exec"
alias macdots="/usr/local/bin/git --git-dir=$HOME/.macdots.git/ --work-tree=$HOME"
alias vi="nvim"
alias vim="nvim"
alias dmux="tmux source-file ~/.config/tmux/dev \; attach"
alias ssh="TERM=xterm ssh"

function git_branch() {

    inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"

    if [ "$inside_git_repo" ]; then
        echo "($(git branch --show-current)) "
    fi
}

RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
GREY="\[$(tput setaf 8)\]"
RESET="\[$(tput sgr0)\]"

if [ $(id -u) -eq 0 ];
then
    PS1="${RED}\u${RESET}@${GREY}\h: ${BLUE}\W ${YELLOW}\$(git_branch)${RESET}\$ "
else
    PS1="${GREEN}\u${RESET}@${GREY}\h: ${BLUE}\W ${YELLOW}\$(git_branch)${RESET}\$ "
fi

# Setup fzf. Use uninstall script to remove fzf.
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
