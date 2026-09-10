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
| Terminal emulator | ghostty, alacritty | `.config/ghostty`, `.config/alacritty` |
| Multiplexer | zellij, tmux | `.config/zellij`, `.config/tmux` |
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
| Agent tooling | Claude Code — config, skills, plugins. serena and headroom MCP servers | `.claude` |
| Git | | `.gitconfig`, `.gitexcludes` |

`.vimrc` is a plugin-free fallback for where neovim cannot follow: sudo,
another account, a machine with nothing installed.

### Terminal and multiplexer

Ghostty and zellij are the pair I launch. Alacritty is the backup and mirrors
the ghostty config: same theme, metrics, padding and font pairing. The two are
kept in step by hand.

tmux is only ever the inner multiplexer, running inside a zellij pane. Two
things put it there: an overmind session, and the Claude agent fan-out `cmux`
starts on its own tmux server. So `.config/tmux` assumes zellij already draws
the outer chrome, and its status line carries the session name and nothing
else.

`dzj` builds the dev workspace from `.config/zellij/layouts/dev.kdl`, and `cmux`
launches the Claude server. Both configs share the Kanagawa Dragon colours and a
`Ctrl \` prefix, so an embedded tmux reads as part of the zellij around it.

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

### Agent tooling

Claude Code is the agent, and `.claude` tracks its own configuration only:
`CLAUDE.md`, `settings.json`, skills and hooks. Two MCP servers sit behind it,
and neither one keeps a publishable config file.

**serena** gives the agent LSP-backed symbol search and symbol-level edits, so
it navigates code instead of grepping for it. Its config sits at
`~/.serena/serena_config.yml`, untracked. Serena rewrites that file whenever it
registers a project, restoring every default value and every template comment,
so a pruned copy does not survive one launch. Three values differ from the
shipped template, and only the modes are worth re-applying by hand, because the
MCP launch args already pass `--open-web-dashboard False`:

```yaml
base_modes:
- no-memories
default_modes:
- interactive
- editing
- query-projects
```

`no-memories` sits in `base_modes` because Basic Memory already owns memory,
and a base mode is the one layer a project config or `--mode` cannot override.
The three default modes stay overridable per call, which is where situational
ones belong.

**headroom** compresses tool and MCP output before it reaches the context
window, which is what keeps a long session inside its budget. It runs as a
launchd daemon, `Library/LaunchAgents/com.headroom.proxy.plist`, whose
`ProgramArguments` point straight at `headroom proxy`. headroom's own
`persistent-service` preset points them at a wrapper script that spawns the
listener as a child, so launchd supervises the wrapper and `KeepAlive` cannot
recover a killed proxy.

`.bash_profile` routes every session through the daemon and carries the two env
vars that a custom `ANTHROPIC_BASE_URL` turns load-bearing: `ENABLE_TOOL_SEARCH`,
without which Claude Code eagerly loads every deferred MCP tool schema, and
`ANTHROPIC_MODEL` with a `[1m]` suffix, without which the session caps at 200k.
Both fail silently.

Most of `~/.headroom` is runtime state and belongs in no repo, but
`settings.json` is configuration and is tracked. It holds the two Kompress keys,
which are not interchangeable and are easy to read as redundant:

- `disable_kompress` turns off the ML paraphraser, and is sufficient on its own.
  The structural compressors — SmartCrusher, log/diff, schema compaction — stay
  on regardless, and their output is lossy. The CCR store recovers an original
  for 30 minutes only, so a long session outlives that window;
  `HEADROOM_LOSSLESS=1` drops the dependency on the store entirely.
- `disable_kompress_fallback` is nested inside the first in the proxy's router
  wiring, so setting it alone does nothing at all. With both set, content that
  no structural compressor claims goes to passthrough rather than the Kompress
  fallback path.

To measure Kompress again, set `disable_kompress` back to `false`. The fallback
key goes inert at that moment whatever its own value says.

## Using this elsewhere

**Cherry-pick it** — in the ordinary sense, not `git cherry-pick`. That is the
recommended way to use this repo and, for most people, the only one worth
bothering with. Nothing here assumes the rest of it, so browse the tree, copy
out the config you want and leave the rest. No clone required; reading it here
on GitHub and pasting what you like is a perfectly good way to do this. You
skip the bare-repo mechanics entirely, and with them the rest of this README.

### Installing the whole thing

Read this the way you would a build-from-source section: it exists for future
me, and for anyone who already knows what a bare dotfiles repo does to a home
directory. It is not the recommended path and it is not reversible in any
casual sense — `$HOME` becomes a git work tree, which changes how git behaves
there from then on.

```bash
git clone --bare git@github.com:m4thayus/macdots.git "$HOME/.macdots.git"
git --git-dir="$HOME/.macdots.git" --work-tree="$HOME" checkout
git --git-dir="$HOME/.macdots.git" --work-tree="$HOME" config status.showUntrackedFiles no
```

`checkout` refuses rather than clobbering anything already in `$HOME`; move
those files aside or delete them, your call. The third line is belt-and-braces
— `.local/bin/macdots` forces it anyway — but it makes the raw `git --git-dir=`
form safe too, and you will be using that until `PATH` picks the script up.

Then read the section below before doing anything else, because from that point
on `$HOME` is a git work tree and that has consequences.

All of this is offered as-is. It is shaped around my machine and my habits, so
expect to adapt it rather than have it fit.

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
> `add -A`, `add .` from `$HOME`, or `clean`. The wrapper forces
> `status.showUntrackedFiles=no` so the bare defaults are instant and safe;
> those flags defeat it. Add explicit paths, always.

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

### Commit messages

Always [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): subject`.

- Types: `feat`, `fix`, `docs`, `refactor`, `chore`.
- Scope is the tool the commit touches — `claude`, `ghostty`, `macdots`, `tmux`,
  `toys`, `zellij`, `zsh`. Omit it only when the change spans the repo.
- Subject in the imperative, lowercase, no trailing period.

**Why:** this work tree is a pile of unrelated configs, so a subject alone rarely says
which tool a commit is about. The scope carries that, and it makes the log filterable by
tool.
