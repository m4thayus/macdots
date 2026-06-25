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
