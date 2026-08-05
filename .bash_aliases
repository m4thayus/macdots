#
# ~/.bash_aliases
#

alias vi="nvim"
alias vim='NVIM_APPNAME="nvim-legacy" nvim'

alias ssh="TERM=xterm ssh"
alias docker="podman"
alias be="bundle exec"

# Points at the script rather than re-spelling the git invocation: an inlined
# --git-dir form here would silently bypass the script's guard against commands
# that walk all of $HOME. See ~/README.md.
alias macdots="$HOME/.local/bin/macdots"

alias dmux="tmux source-file ~/.config/tmux/dev \; attach"
alias pmux="tmux source-file ~/.config/tmux/prose \; attach"
alias hgmux="tmux source-file ~/.config/tmux/mercury \; attach"

alias rc_sync="rclone sync --fast-list --progress --track-renames --exclude-from $HOME/.config/rclone/exclude.conf --transfers 16"
alias rc_copy="rclone copy --fast-list --progress --track-renames --exclude-from $HOME/.config/rclone/exclude.conf --transfers 16"
