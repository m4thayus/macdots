if [[ $(uname -m) == arm64 ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
  export PATH="$(brew --prefix)/opt/postgresql@11/bin:$PATH" # for talaria
fi

if [[ $(hostname) == lilith.local ]]; then
  export MERCURY_BASE_PATH="$HOME/Projects/mercury"
else
  export MERCURY_BASE_PATH="$HOME/Projects"
fi

export PATH="$PATH:$HOME/.local/bin"
export FIGNORE="$FIGNORE:.DS_Store"
export VISUAL=nvim
export EDITOR=nvim
export CDPATH=".:$HOME:$HOME/Projects:$MERCURY_BASE_PATH"
export AWS_USER=mattw
export DELTA_PAGER="less -RC"
export PROMPT_COMMAND='echo -ne "\033]0;${PWD/$HOME/~}\007"'
export FZF_DEFAULT_COMMAND="rg --files --hidden"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --bind=tab:down,btab:up,down:toggle+down,up:toggle+up"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS --select-1 --exit-0"
export BUNDLE_LOCAL__MERCURY_SSO_AUTH0="$MERCURY_BASE_PATH/mercury-analytics-sso-auth0"
export BUNDLE_LOCAL__URI_S3="$MERCURY_BASE_PATH/uri_s3"

eval "$(rbenv init -)"
eval "$(nodenv init -)"
eval "$(direnv hook bash)"

[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"

source ~/.bashrc
