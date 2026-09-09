if [[ $(uname -m) == arm64 ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

export PATH="$PATH:$HOME/.local/bin"
export FIGNORE="$FIGNORE:.DS_Store:Icon?"
export VISUAL=nvim
export EDITOR=nvim
export MERCURY_BASE_PATH="$HOME/Projects/mercury"
export CDPATH=".:$HOME:$HOME/Projects:$MERCURY_BASE_PATH:$HOME/Documents"
export AWS_USER=mattw
export AWS_PROFILE=mercury
export DELTA_PAGER="less -RC"
export PROMPT_COMMAND='echo -ne "\033]0;${PWD/$HOME/~}\007"'

export FZF_DEFAULT_COMMAND="rg --files --hidden"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --bind=tab:down,btab:up,down:toggle+down,up:toggle+up"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS --select-1 --exit-0"

export FX_THEME=2
export FX_SHOW_SIZE=true
export FX_NO_MOUSE=true

# Headroom: disable telemetry, the update check and the license reporter. It does not
# gate model downloads, because the Kompress loader never consults it (v0.37.0).
# Set globally so wrapped and unwrapped sessions behave the same.
export HEADROOM_OFFLINE=1

# Turn off the Kompress-v2-base paraphraser. The structural compressors (SmartCrusher,
# log/diff, schema compaction) stay on, and their output is lossy. The CCR store
# recovers an original for 30 minutes only, so a long session outlives that window.
# HEADROOM_LOSSLESS=1 removes the dependency on the store.
export HEADROOM_DISABLE_KOMPRESS=1

# HEADROOM_TEXT_CRUSHER stays unset. Turned on, prose over HEADROOM_KOMPRESS_MAX_TOKENS
# (default 50k tok) would route to the extractive TextCrusher, which drops whole
# sentences. That gate sits ABOVE the enable_kompress check, so DISABLE_KOMPRESS does
# not cover it — only its own default-off does (v0.37.0). Setting =0 is a no-op: the
# parse is a whitelist, so "0" and unset take the same branch.

eval "$(rbenv init -)"
eval "$(nodenv init -)"
eval "$(direnv hook bash)"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

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
