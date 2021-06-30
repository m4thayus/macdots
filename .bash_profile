export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/postgresql@11/bin:$PATH" # for talaria
export PATH="$PATH:$HOME/.local/bin"
export FIGNORE="$FIGNORE:.DS_Store"
export VISUAL=nvim
export EDITOR=nvim
export CDPATH=".:$HOME:$HOME/Projects"
export AWS_USER=mattw
export DELTA_PAGER="less -RC"
export PROMPT_COMMAND='echo -ne "\033]0;${PWD/$HOME/~}\007"'
export FZF_DEFAULT_COMMAND="rg --files --hidden"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS --select-1 --exit-0"
# export FZF_COMPLETION_OPTS="$FZF_CTRL_T_OPTS" # Completion was removed

eval "$(rbenv init -)"
eval "$(nodenv init -)"
eval "$(direnv hook bash)"

# Bash Completion:
# Use `brew install bash-completion`
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

source ~/.bashrc
