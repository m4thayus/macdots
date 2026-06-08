#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi

$(toys system bash-completion install)

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi

source ~/.bash_aliases
