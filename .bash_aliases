#
# ~/.bash_aliases
#

alias vi="nvim"
alias vim="nvim"

alias ssh="TERM=xterm ssh"
alias docker="podman"
alias be="bundle exec"

alias macdots="$(brew --prefix)/bin/git --git-dir=$HOME/.macdots.git/ --work-tree=$HOME"

alias dmux="tmux source-file ~/.config/tmux/dev \; attach"
alias pmux="tmux source-file ~/.config/tmux/prose \; attach"
alias hgmux="tmux source-file ~/.config/tmux/mercury \; attach"

alias rc_sync="rclone sync --fast-list --progress --track-renames --exclude-from $HOME/.config/rclone/exclude.conf --transfers 16"
alias rc_copy="rclone copy --fast-list --progress --track-renames --exclude-from $HOME/.config/rclone/exclude.conf --transfers 16"
