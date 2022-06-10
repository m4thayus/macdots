if [[ $(uname -m) == arm64 ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
  export PATH="$(brew --prefix)/opt/postgresql@11/bin:$PATH" # for talaria
fi

export PATH="$PATH:$HOME/.local/bin"
export FIGNORE="$FIGNORE:.DS_Store:Icon?"
export VISUAL=nvim
export EDITOR=nvim
export MERCURY_BASE_PATH="$HOME/Projects/mercury"
export CDPATH=".:$HOME:$HOME/Projects:$MERCURY_BASE_PATH:$HOME/Documents"
export AWS_USER=mattw
export DELTA_PAGER="less -RC"
export PROMPT_COMMAND='echo -ne "\033]0;${PWD/$HOME/~}\007"'
export FZF_DEFAULT_COMMAND="rg --files --hidden"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --bind=tab:down,btab:up,down:toggle+down,up:toggle+up"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS --select-1 --exit-0"

eval "$(rbenv init -)"
eval "$(nodenv init -)"
eval "$(direnv hook bash)"

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

[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"

source ~/.bashrc
