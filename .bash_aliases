#
# ~/.bash_aliases
#

alias vi="nvim"

alias ssh="TERM=xterm ssh"
alias docker="podman"
alias be="bundle exec"

# Points at the script rather than re-spelling the git invocation: an inlined
# --git-dir form here would silently bypass the script's guard against commands
# that walk all of $HOME. See ~/README.md.
alias macdots="$HOME/.local/bin/macdots"

# Claude with agent teams, on its own tmux server (-L) so the fan-out panes stay
# out of the session you launched from. Layout lives in claude.conf. Teams stay
# off in settings.json, which keeps their context cost a per-launch choice.
# printf %q keeps quoted flag values intact, since tmux takes one command string.
cmux() {
  local cmd=claude arg
  for arg in "$@"; do cmd+=" $(printf '%q' "$arg")"; done
  TMUX= tmux -L claude -f ~/.config/tmux/claude.conf \
    new-session -A -s "${PWD##*/}" -c "$PWD" \
    -e CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 "$cmd"
}

# The dev workspace, via ~/.config/zellij/layouts/dev.kdl. zellij is the
# multiplexer you launch, and tmux only ever runs embedded in one of its panes.
# The subcommand order is not stylistic: `zellij --layout X --session Y` is broken
# in 0.45.1 and exits with "There is no active session!", so the layout has to
# arrive as a default-layout override on an attach --create instead.
alias dzj="zellij attach --create dev options --default-layout dev"

# zellij's own suggested shorthand, and where dzj's suffix comes from.
alias zj="zellij"

alias rc_sync="rclone sync --fast-list --progress --track-renames --exclude-from $HOME/.config/rclone/exclude.conf --transfers 16"
alias rc_copy="rclone copy --fast-list --progress --track-renames --exclude-from $HOME/.config/rclone/exclude.conf --transfers 16"
