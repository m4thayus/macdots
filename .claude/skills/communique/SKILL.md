---
name: communique
description: Use before any text leaves this session for a human other than Matt — a Slack message or DM, a PR review body or comment, an issue body, a commit message someone else reads. Covers drafting the wording, showing it to Matt before it sends, writing for a recipient who has none of this session's context, and repairing something already sent. Triggers on "send this", "post it", "reply to them", "comment on the PR", "request changes", "DM them", "write the commit message", and any gh pr review, gh pr comment or Slack send.
---

# Communique

Anything leaving this session for a human other than Matt. Slack messages and DMs, PR review
bodies and comments, issue bodies, commit messages others will read.

## Show the wording before it goes out

Draft the body, show it inline, and ask — even when Matt has already said "post it", "send it"
or "request changes".

**The instruction authorizes the action, not the wording.** "Put together our findings and
request changes" means assemble and be ready. It does not mean fire.

**Why:** these go to real people. Tone and framing are the part Matt most wants final say on,
and once sent they re-ping and cannot be cleanly unsent.

## Tag the first mention

Use the platform's mention syntax the first time you name someone, so they get alerted. Every
later mention in the same message is the bare name.

- GitHub: `@handle`
- Slack: `<@U01ABCDEF>`, which renders as their display name

Handles and Slack IDs live in the `mercury` memory scope.

## If it already went out

Offer the repair rather than leaving it.

- PR review bodies edit in place: `gh api PATCH /repos/{owner}/{repo}/pulls/{n}/reviews/{id}`
- PR and issue comments edit and delete
- Slack messages edit

## Assume the recipient has none of our context

Unless there is positive evidence otherwise — they were on the thread, it is in the PR, they
said it themselves — everything discussed in this session is invisible to them.

Two consequences:

1. Never retract or amend something they never received. A draft shown only to Matt does not
   exist to them.
2. Never drop in a detail that surfaced in side discussion without introducing it fresh.

Reread every reference as the recipient before sending. Anything they have not seen either gets
stated as new, with its why, or gets cut.

**Why:** unexplained context is worse than no context. It sends them hunting for a message they
never got, or assuming they forgot something. On a long-running review that is actively
corrosive, because each round then has both sides working from information the other lacks.

## Matt's edits to a draft are proposals, not copy to transcribe

When Matt responds to draft wording he is reacting to the substance and steering it. Take each
note as a constraint or a correction. Reconcile it against the rest of the message, drop what it
makes redundant, and rewrite.

**Why:** pasting spoken notes straight through produces a worse message than either of us would
write. It abandons judgment exactly where judgment matters — what to include, what a colleague
can act on, what needs no saying.

## Two habits to drop on the way through

1. Preemptively absolving the recipient. "So you applied the rule correctly", "that's not on you".
2. Reaching for a specific example when a general statement is what was asked for.
```
