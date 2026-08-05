# Global Claude Instructions

## Always Capture the Why

When writing memory entries, documenting decisions, recommending deferrals, or noting trade-offs: always include the reasoning, not just the conclusion. Future context needs to know *why* a decision was made to judge whether it still applies — not just what was decided.

This applies to:
- Memory file entries (`**Why:**` lines)
- Inline code comments on non-obvious decisions
- PR descriptions and commit messages
- Any time I'm recording that something was deferred or chosen over an alternative

## Boy Scout Rule (calibrated)

Leave the files you touch better than you found them. When a change makes something redundant — a now-dead parameter, a vestigial wrapper, inert config, a no-longer-used export, an alias that just forwards — remove it in the same change. Before calling work done, re-scan the files you edited (and anything your change made redundant) for that adjacent cruft; treat it as part of verification, not an optional polish pass.

**This is cleanup of what you touched, not a license to refactor everything in sight.** It pairs with YAGNI / anti-over-engineering and never overrides them:
- Don't add abstractions, pull helpers "up" speculatively, or improve code you aren't otherwise touching.
- Don't expand scope to chase cruft. If a cleanup would balloon the change, note it as a follow-up (with the why) instead of doing it inline.
- Incidental sameness isn't a reason to abstract; a thin wrapper that only saves typing isn't worth keeping.

The recurring failure mode this guards against is leaving a half-done state after a change — and, after a merge that mixes someone else's work into files you refactored, assuming the cleanup "stuck" without re-checking. Re-scan; don't assume.

## `$HOME` Is a Git Work Tree

My dotfiles are a bare repo whose work tree is **all of `$HOME`**, driven by
`~/.local/bin/macdots` (also aliased `macdots`). Read the "Working in this
repo" section of `~/README.md` before running it.

- **Never** `macdots status -u` / `-uall` / `--untracked-files=...`, `add -A`,
  `add .` from `$HOME`, or `clean`. Each walks every file on the machine, which
  has locked it up badly enough to need a reboot. `status.showUntrackedFiles=no`
  plus an allowlist `~/.gitignore` keep the defaults safe; those flags defeat
  both. Add explicit paths, always — the repo is public.
- **To enumerate files under `$HOME`, reach for `ls`/`fd`, not git.** Git here
  is for the tracked set only — if the question is "what's in this directory",
  git is the wrong tool and the expensive one.
- Use `macdots`, never a hand-rolled `git --git-dir=$HOME/.macdots.git ...`.
  The wrapper carries the guard; the raw form silently bypasses it.
- Pathspecs resolve against cwd, not `$HOME`. `cd ~` first or use full paths.
- **This repo is public — keep commit messages to what changed and the durable
  why.** A message that spells out what a change was defending against is a map
  of the weakness for anyone reading back through history. Rules in tracked
  docs have to name specifics to function; history does not.

**Why:** tracking dotfiles where they actually live (rather than symlinking
them out of a single directory) is the whole point of the design, but it means
normal git reflexes are actively wrong here. Treat any whole-tree operation as
suspect, and show me the command and its blast radius before running it.

## Delegate Code Search to Subagents

When getting bearings on scope in a large repo, dispatch a subagent (Explore / general-purpose) to do the grepping and file-reading and return only the distilled results. Do NOT run broad greps or bulk file Reads in the main context.

**Why:** Broad searches shove a lot into the main context window. I run long, wide-ranging conversations rather than one-off tasks, and want the main window kept low (target well below 20%) so we can keep going without summarization. Getting-bearings work otherwise eats 7–10% up front.

**How to apply:**
- Broad / uncertain search (naming conventions, "where does X live", multi-file sweeps) → subagent, results only.
- Single known lookup (file + rough line already known) → just Read the narrow slice directly; a subagent there is slower and buys nothing.
- Large PR diff review → don't read the whole diff into the main context. Before doing so, ask whether it's worth it; default to dispatching subagents (per-file or per-area) that return findings only, then I reason over the findings. Read specific hunks directly only when a finding needs closer judgment. Small diffs where reading it all is cheap → just read it.
