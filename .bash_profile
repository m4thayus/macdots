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

# Every Anthropic request goes through the headroom proxy that
# ~/Library/LaunchAgents/com.headroom.proxy.plist keeps running, so the port has to
# match the plist. A dead daemon breaks the CLI, which is intended: falling back to
# un-proxied traffic spends the tokens the proxy exists to save.
export ANTHROPIC_BASE_URL=http://127.0.0.1:8787

# The next two are load-bearing only because the base URL above is a custom host,
# and both are silent when they go missing.
#
# Claude Code turns OFF on-demand tool loading behind a custom base URL unless this
# is set, materialising every deferred MCP tool schema into the window — tens of
# thousands of tokens per session (headroom issue #746).
export ENABLE_TOOL_SEARCH=true

# Claude Code only sends the context-1m beta header when the model id carries the
# [1m] suffix, and behind a custom base URL its /model picker selection does not
# survive. Unset, the session caps at 200k (headroom issue #1158). Pass --model to
# override; the flag outranks this.
export ANTHROPIC_MODEL="claude-opus-5[1m]"

# Off in every headroom process, or the beacon uploads from whichever one is missed.
# It is not a ~/.headroom/settings.json knob and launchd reads no shell rc, so it is
# duplicated in com.headroom.proxy.plist. Change both together.
export DO_NOT_TRACK=1

# Compression knobs live in ~/.headroom/settings.json, which every headroom process
# applies at startup. HEADROOM_TEXT_CRUSHER is the exception, because the store does
# not carry it, so it can only be set here and it stays unset. Turned on, prose over
# HEADROOM_KOMPRESS_MAX_TOKENS (default 50k tok) would route to the extractive
# TextCrusher, which drops whole sentences. That gate sits ABOVE the enable_kompress
# check, so disable_kompress does not cover it (v0.37.0). Setting =0 is a no-op: the
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
