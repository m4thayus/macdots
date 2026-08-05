# m4thayus's macOS dotfiles

Configuration for my (macOS-based) dev environment, managed as a bare git repo
(`git --git-dir=$HOME/.macdots.git --work-tree=$HOME`, aliased `macdots`).

> [!CAUTION]
> The work tree is all of `$HOME`, so ordinary git reflexes are wrong here and
> a few of them are destructive. Read [Working in this
> repo](#working-in-this-repo) before running `macdots`.

## What's configured

| Area | Tooling | Config |
| --- | --- | --- |
| Terminal emulator | kitty, alacritty | `.config/kitty`, `.config/alacritty` |
| Multiplexer | tmux | `.config/tmux` |
| Editor | neovim — Lua config, `init.lua` + `lua/`, lazy.nvim | `.config/nvim` |
| Window management | Amethyst | `.amethyst.yml` |
| Ruby | rbenv, bundler | `.rbenv/version`, `.bundle/config` |
| Node | nodenv | `.nodenv/version` |
| Environment | direnv | |
| Linting | rubocop, eslint, coffeelint | `.rubocop.yml` |
| Search & QoL | fzf, ripgrep, bat | `.config/bat`, `.ignore` |
| Spell checking | codebook | `.config/codebook` |
| Worktrees | worktrunk | `.config/worktrunk` |
| Sync | rclone | `.config/rclone` |
| Log analysis | goaccess | `.goaccessrc` |
| Agent tooling | Claude Code — config, skills, plugins | `.claude` |
| Git | | `.gitconfig`, `.gitexcludes` |

The legacy `.vimrc` and `.config/nvim-legacy/init.vim` are deprecated
coc-based backups, kept only as a fallback.

### `.toys/` — custom commands

Built on [Toys](https://github.com/dazuma/toys), grouped by namespace and run
as `toys <namespace> <command>`:

| Namespace | Commands |
| --- | --- |
| **github** | `prune local` / `prune remote` — clean up merged, closed and foreign branches, dry-run by default, `--apply` to delete. `stale` — open PRs oldest-first. `notable` — link to notable recent PRs |
| **aws** | MFA auth and EC2 host lookup |
| **dataurl** | Encode and decode images as base64 `data:` URLs |
| **ffmpeg**, **backgrounds**, **text** | Media and text helpers |
| **rails**, **talaria**, **thoth** | Project dev shortcuts |

## Working in this repo

`macdots` is a script at `.local/bin/macdots`, on `PATH`, so it works from any
shell — zsh, scripts, cron, coding agents. The `.bash_aliases` entry points at
that script; don't re-inline the raw `git --git-dir=...` form anywhere, since
that bypasses the guard it carries.

**The work tree is all of `$HOME`.** That is the design — dotfiles stay tracked
where they actually live instead of being collected into a directory and
symlinked back — but it means this repo does not behave like a normal one. It
is also public, and the work tree holds a great deal that should never be
published.

> [!WARNING]
> Anything that walks *untracked* files touches every file on the machine. That
> is not merely slow: it has locked this machine hard enough to need a reboot.
> Never run `macdots status -u` (or `-uall`, `--untracked-files=...`),
> `add -A`, `add .` from `$HOME`, or `clean`. The repo sets
> `status.showUntrackedFiles=no` so the bare defaults are instant and safe;
> those flags defeat that. Add explicit paths, always.

Otherwise:

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
