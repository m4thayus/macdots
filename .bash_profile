export PATH="/usr/local/opt/postgresql@11/bin:$PATH" # for talaria
export PATH="$PATH:$HOME/.local/bin"
export FIGNORE="$FIGNORE:.DS_Store"
export VISUAL=nvim
export EDITOR=nvim
export CDPATH=".:$HOME:$HOME/Projects"

eval "$(rbenv init -)"
eval "$(nodenv init -)"
eval "$(direnv hook bash)"

# Bash Completion:
# Use `brew install bash-completion`
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

source ~/.bashrc
