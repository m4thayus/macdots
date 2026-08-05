# m4thayus's macOS dotfiles

Configuration for my (macOS-based) dev environment, managed as a bare git repo
(`git --git-dir=$HOME/.macdots.git --work-tree=$HOME`, aliased `macdots`).

`macdots` is a script at `.local/bin/macdots`, on `PATH`, so it works from any
shell — zsh, scripts, cron, coding agents. The `.bash_aliases` entry just
points at that script; don't re-inline the raw `git --git-dir=...` form
anywhere, because that bypasses the safety guard described below.

## Working in this repo — read before running `macdots`

**The work tree is all of `$HOME`.** That is the design — dotfiles stay tracked
where they actually live instead of being collected into a directory and
symlinked back — but it means this repo does not behave like a normal one, and
the usual git reflexes are wrong here. It is also public, and the work tree
holds a great deal that should never be published.

Anything that walks *untracked* files touches every file on the machine. That
is not merely slow: it has locked this machine hard enough to need a reboot.

So:

- **Never `macdots status -u`** (or `-uall`, `--untracked-files=...`),
  **`add -A`**, **`add .` from `$HOME`**, or **`clean`**. The repo sets
  `status.showUntrackedFiles=no` so the bare defaults are instant and safe;
  those flags defeat that. Add explicit paths, always.
- `macdots add -u` is fine — tracked files only.
- **To list files, use `ls` / `fd`, not git.** Git here is for the tracked set.
  For "what is in this directory" it is the wrong tool and the expensive one.
- Pathspecs resolve against your cwd, exactly as in any repo — the wrapper
  deliberately does not reroute to `$HOME`. The only wrinkle is that the root
  sits far above you, so a relative path from a deep subdirectory can quietly
  match nothing. `cd ~` or use an absolute path when in doubt.

`.gitignore` is an allowlist: everything is ignored unless explicitly admitted,
so the default for anything new is "not published" and untracked walks stay
cheap. Newly tracked files need a line there, which shows up as `add` refusing
the file. `.local/bin/macdots` additionally refuses the commands above.

Neither layer is airtight — ignore rules do not untrack anything already
committed, and a hand-rolled `git --git-dir=...` bypasses the wrapper entirely.
They shrink the blast radius; they don't remove it.

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
