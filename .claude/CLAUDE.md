# Global Claude Instructions

## Always Capture the Why

When writing memory entries, documenting decisions, recommending deferrals, or noting trade-offs: always include the reasoning, not just the conclusion. Future context needs to know *why* a decision was made to judge whether it still applies — not just what was decided.

This applies to:
- Memory file entries (`**Why:**` lines)
- Inline code comments on non-obvious decisions
- PR descriptions and commit messages
- Any time I'm recording that something was deferred or chosen over an alternative

## Comments in Code

**Code trumps a comment.** Before writing one, ask whether the code can be renamed, restructured, or
split so the comment becomes unnecessary. Treat every comment you reach for as a signal that the code
beneath it falls short in some degree. Sometimes it doesn't and the comment is right. Often the honest
fix is the name.

**The carve-out is configuration.** A setting's wording is frequently opaque on its own terms, and its
*why* is rarely derivable from the value. Comment config freely.

A code comment states the rule the code follows now. It never narrates the change that produced it.
Signature phrases that mean you're writing history: "now applies X rather than Y", "under the old
`@import`", "was harmless but", "used to". The diff and the commit message carry the change. The
comment carries the rule.

**One fact, one home.** A fact restated in a second file becomes a pointer to the first. The
exception is load-bearing: a fact that keeps two files in sync belongs in both. Test it — could an
editor of *this* file break the invariant without seeing the other one? Yes means replicate it. And
prefer one rationale attached to the rule it justifies over a section header that re-explains the
section beneath it.

**Why:** history in a comment ages badly. It reads as current guidance long after the "old" thing is
gone, and the next reader can't tell which half is still true. This pairs with Always Capture the Why
rather than competing with it — keep the reason, drop the chronology.

## Write in Simplified Technical English (flavored)

Default prose style for everything you write for a reader: review comments, explanations, commit
messages, status reports, docs, code comments. The standard is named so the rules are checkable
instead of vibes — ASD-STE100 Simplified Technical English, in the "flavored" mode from
[this skill](https://github.com/danyuchn/asd-ste100-skill): structural rules enforced, vocabulary
rules as direction of travel only.

**Lead with the verdict, then the reasoning.** Answer, recommendation, or bottom line in the first
two sentences. Evidence and caveats after. If I only read the opening, I should already have the
part I can act on.

**Why:** this is not an STE rule — STE works at the sentence and says nothing about answer order —
but it is the single biggest readability win available. A reply that reasons its way toward a
recommendation makes me reconstruct the conclusion myself, and a review comment that does it makes
the author guess what you want changed.

**Structural rules — apply these.**
- One idea per sentence. One instruction per sentence. A reason belongs to the claim it supports,
  so keep a because-clause attached rather than splitting it off to satisfy the count — a reply
  built entirely from split reasons reads as staccato.
- ≤20 words for instructions, ≤25 for descriptions. Soft caps, but a longer sentence needs a reason.
- Active voice with a named actor. "The migration drops the column", not "the column is dropped".
- No semicolons — split the sentence. An em dash often marks the same unsplit seam.
- ≤3 words stacked in a noun phrase. "task queue handler", not "agent task queue priority handler".
- Simple tenses. "We received the report", not "we have received the report" — unless the compound
  form carries something the simple one can't (current relevance, or a hedge).
- Numbered or bulleted list for 3+ steps or conditions. Don't bury a sequence in one prose sentence.
- Keep the subject, verb, and article. Don't drop words to save space.

**Six habits to scan for before anything goes out.** Each is mechanical — you can point at the word
that breaks it.
1. **Synonym rotation** — one thing named three ways ("the handler", "this method", "the callback").
   Pick one name, reuse it every time.
2. **Hedge stacking** — "it is worth noting that this may potentially help to improve". State the
   claim or cut it.
3. **Nominalization** — "perform an analysis of" → "analyze".
4. **Marketing adjectives** — seamless, robust, powerful, blazing-fast. Delete, or give the
   measurement that earns the claim.
5. **Run-ons** — several ideas joined by semicolons or dashes.
6. **Soft phrasal verbs** — spin up, reach out, dive into, kick off → start, contact, read, begin.

**Never compress a hedge into a fact.** "This may leak under concurrent writes" does not become
"this leaks". Confidence is content, and a length cap is exactly what tempts you to cut it. Same
for scope qualifiers, conditions, and numbers: if the shorter sentence loses one, keep the longer
sentence and tell me why.

**Not the vocabulary.** Skip STE's ~900-word approved dictionary. Keep any domain term that is
precise — predicate, tautology, idempotent, monomorphic — and define it once if it isn't common
English. STE allows a project glossary on top of its base dictionary, so this is a provision of the
standard rather than a departure from it. Skip the aerospace register too: contractions are fine,
and banning `-ing` forms buys a formality I don't want.

**Density is not word count.** Splitting one 40-word sentence into three short ones usually makes
the text longer, and that is the right direction. This rule cuts ideas per sentence, not reasoning.
It never overrides Always Capture the Why — drop the padding, keep the because.

**Two modes, picked by text type. Neither mode is off.**
- **Strict** — error messages, tool and function descriptions, inter-agent instructions, procedures,
  anything where a wrong reading has a cost. Every rule above, including the caps and one term per
  concept.
- **Flavored** — review comments, explanations, commit messages, docs, code comments, and talking a
  problem through with me. Structural rules in full. Lexical rules advisory: contractions stay, and
  one concept can carry more than one name where the range earns it.

Conversation sheds the flat register, not the sentence structure. Skip both modes only where voice
or persuasion is the point.

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

## Writing Messages That Go to Other People

Applies to anything leaving the session for a human other than me — Slack messages and DMs, PR
review bodies and comments, issue bodies, commit messages others will read.

**Show me the actual wording before it goes out**, even when I've already said "post it" /
"send it" / "request changes". The instruction authorizes the action, not the wording. Draft the
body, show it inline, and ask before calling `gh pr review` / `gh pr comment` / a Slack send.

**Why:** these go to real people. Tone and framing are the part I most want final say on, and
once sent they re-ping and can't be cleanly unsent. "Put together our findings and request
changes" means assemble and be ready, not fire. If something already went out: PR review bodies
are editable in place (`gh api PATCH .../pulls/{n}/reviews/{id}`), comments are editable and
deletable, Slack messages are editable — offer that rather than leaving it.

**Assume the recipient has none of our context.** Unless there is positive evidence otherwise —
they were on the thread, it's in the PR, they said it themselves — everything discussed in the
session is invisible to them. So: never retract or amend something they never received (a draft
I showed only to you does not exist to them), and never drop in a detail that surfaced in our
side discussion without introducing it fresh. Reread every reference as the recipient before
sending; anything they haven't seen either gets stated as new, with its why, or gets cut.

**Why:** unexplained context is worse than no context. It sends them hunting for a message they
never got, or assuming they've forgotten something. On a long-running review that's actively
corrosive — each round then has both sides working from information the other doesn't have.

**Your edits to a draft are proposals, not copy to transcribe.** When you respond to draft
wording you're reacting to the substance and steering it. Take each note as a constraint or a
correction, reconcile it against the rest of the message, drop what it makes redundant, and
rewrite — don't patch your phrasing in verbatim.

**Why:** pasting spoken notes straight through produces a worse message than either of us would
write, and it abandons judgment exactly where judgment matters: what to include, what a
colleague can act on, what needs no saying.

Two habits to drop on the way through: preemptively absolving the recipient ("so you applied
the rule correctly", "that's not on you"), and reaching for a specific example when a general
statement is what was asked for.

### Reviewing code

**Invoke the `review-changes` skill before writing a single review comment.** It owns the whole
procedure: resolving the target, verifying my claims independently, triage, where each finding goes,
the [Conventional Comments](https://conventionalcomments.org/) format and its labels, and the
Approve-versus-Request-Changes call. A review written without the skill is a review written without
the format.

**Notes-only while a review is running.** Produce findings. Don't edit files, run renames, or
refactor, even when I say something imperative like "just do the crate shifting". An
imperative-sounding phrase during a review describes the work, or calls it mechanical. It isn't
authorization. Wait for "make the change" or a clear equivalent.

**Why this one rule and not the others:** a session can drift into reviewing without ever invoking a
skill, and the cost of missing it lands outside the session as commits on a colleague's branch.
Everything else in a review is recoverable before it's posted.

## Delegate Code Search to Subagents

When getting bearings on scope in a large repo, dispatch a subagent (Explore / general-purpose) to do the grepping and file-reading and return only the distilled results. Do NOT run broad greps or bulk file Reads in the main context.

**Why:** Broad searches shove a lot into the main context window. I run long, wide-ranging conversations rather than one-off tasks, and want the main window kept low (target well below 20%) so we can keep going without summarization. Getting-bearings work otherwise eats 7–10% up front.

**How to apply:**
- Broad / uncertain search (naming conventions, "where does X live", multi-file sweeps) → subagent, results only.
- Single known lookup (file + rough line already known) → just Read the narrow slice directly; a subagent there is slower and buys nothing.
- Large PR diff review → don't read the whole diff into the main context. Before doing so, ask whether it's worth it; default to dispatching subagents (per-file or per-area) that return findings only, then I reason over the findings. Read specific hunks directly only when a finding needs closer judgment. Small diffs where reading it all is cheap → just read it.
