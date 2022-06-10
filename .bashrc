#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi

alias be="bundle exec"
alias macdots="$(brew --prefix)/bin/git --git-dir=$HOME/.macdots.git/ --work-tree=$HOME"
alias vi="nvim"
alias vim="nvim"
alias dmux="tmux source-file ~/.config/tmux/dev \; attach"
alias hgmux="tmux source-file ~/.config/tmux/mercury \; attach"
alias ssh="TERM=xterm ssh"
alias rc_sync="rclone sync --fast-list --progress --track-renames --exclude-from $HOME/.config/rclone/exclude.conf --transfers 16"
alias rc_copy="rclone copy --fast-list --progress --track-renames --exclude-from $HOME/.config/rclone/exclude.conf --transfers 16"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION
