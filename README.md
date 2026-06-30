# m4thayus's macOS dotfiles

Configuration for my (macOS-based) dev environment, managed as a bare git repo
(`git --git-dir=$HOME/.macdots.git --work-tree=$HOME`, aliased `macdots`).

A short list of configured apps and tools:

- Terminal Emulator: kitty or alacritty with tmux as a multiplexer
- Text Editor: neovim, modern Lua config at `.config/nvim` (`init.lua` + `lua/`,
  lazy.nvim). The legacy `.vimrc` / `.config/nvim-legacy/init.vim` are
  deprecated backups.
- Ruby Versioning: rbenv
- Node Versioning: nodenv
- Local Environment Configuration: direnv
- Linting: eslint, coffeelint, and rubocop
- QoL: coc, fzf, and ripgrep
- aws (just an auth script to keep up with mfa)
- Agent tooling: `.claude` (Claude Code config, skills, plugins)

## `.toys/` — command-line tools

Custom commands built on [Toys](https://github.com/dazuma/toys), grouped by
namespace and run as `toys <namespace> <command>`:

- **github** — `prune local` / `prune remote` (clean up merged/closed/foreign
  branches, dry-run by default; `--apply` to delete), `stale` (open PRs
  oldest-first), `notable` (link to notable recent PRs)
- **aws** — MFA auth + EC2 host lookup
- **dataurl** — encode/decode images as base64 `data:` URLs
- **ffmpeg**, **backgrounds**, **text** — media and text helpers
- **rails**, **talaria**, **thoth** — project dev shortcuts
