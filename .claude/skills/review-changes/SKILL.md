---
name: review-changes
description: Use when reviewing code changes. Covers a PR, a branch, a diff, changes since a commit, and your own work before you open a PR. Produces findings, inline comments in Conventional Comments format, and an Approve or Request Changes verdict. It never edits the code. Triggers on "review this PR", "review #1234", "review my branch", "review changes since main", "look at this PR", "request changes", and a self-review before opening a PR.
---

# Review Changes

## What this skill owns

This skill owns the conduct of a review. That means five things.

1. Verifying what the author claims, independently.
2. Deciding which findings are real.
3. Deciding where each finding goes.
4. Writing each comment.
5. Choosing the verdict.

It does not own applying fixes. See **Boundaries**.

**The output is a draft, never a posted review.** Assemble the body and every comment. Show them.
Wait for approval. Posting is the user's decision every time.

**The audience is the author, not the user running the review.** Write every line of the body and
every comment for the person who wrote the code. Anything addressed to the user belongs in the
session instead, because the author has no use for it and no context for it.

## Four rules that bind the whole pass

**1. Notes-only. Produce findings. Do not edit.**

Run no Edit, no Write, and no `git mv` during a review. An imperative-sounding phrase during a review
describes the work. It does not authorize the work. "Just do the crate shifting" characterizes a
change as mechanical. Only "make the change", or a clear equivalent, authorizes one.

Detect whose branch it is before any edit. Run `git log <base>..HEAD --format='%an'`. If the user
authored no commits, the branch belongs to someone else. Treat it as review mode until told
otherwise.

Self-review does not relax this rule on its own. Produce the findings first. Applying them is a
separate step the user asks for.

**Why:** editing another person's branch steps on their work. The value of a review is the
conclusions the user can relay, not commits nobody asked for.

**2. Post once.**

Accumulate findings in a scratch file outside the repo. Never post per file as the walk proceeds.
Post the whole review in one pass at the end.

**Why:** piecemeal comments fragment the review. They re-ping the author on every push. They lose
the big-picture framing that makes one considered pass readable.

One exception: a batch of self-contained non-blocking cleanup the author can clear in parallel, such
as a set of type errors. Post that as a standalone comment. Nothing else qualifies.

**3. Show the wording before it goes out. Every time.**

Draft the body and every comment. Show them inline. Ask before calling `gh pr review`,
`gh pr comment`, or any equivalent. This applies to follow-up thread replies too. "Post it"
authorizes the action, not the wording.

**4. Never let another tool post or edit for you.**

Other review tools can generate findings. Do not pass `--comment` or `--fix` to any of them. Both
skip rule 3, and `--fix` also breaks rule 1. Do not run `/simplify` during a review, because it
applies fixes.

## When to stop and raise it with the user

Raise these in the session. Never write them into the draft.

1. **A leaked secret, a credential, or a data-loss risk.** Stop before writing it anywhere. A PR
   comment is frequently public, and it cannot be cleanly unsent.
2. **The premise or the scope of the change looks wrong.** That is a conversation, not a comment. An
   inline `issue:` buries a design disagreement in a line annotation.
3. **Two axes contradict each other and reading the hunk does not settle it.** Ask rather than
   picking one.

**Report the conflicts you did settle.** Give each cross-axis contradiction one line in the session,
with the call you made. Never resolve one silently. Keep it brief and let the user ask for the detail.

A finding that flips the verdict is not an escalation. Recommend the verdict and let the user override
it.

## Step 0. Resolve the target

Resolve the target before reading any code. Use the first of these that applies.

1. An explicit argument. A PR number, `owner/repo#N`, a URL, a branch name, a commit or tag, or `.`
   for the working tree.
2. No argument. Run `gh pr view --json number,title,body,headRefName,author`.
3. No PR for the branch. Diff against the merge-base, and say that is what you are reviewing.
4. Ambiguous, or not a git repo. Ask. Do not guess a target.

Confirm the base ref resolves and the diff is not empty. Capture one diff command and reuse it:
`git diff <base>...HEAD`. Use three dots so the comparison runs against the merge-base. Capture the
commit list with `git log <base>..HEAD --oneline`.

Fail here on a bad ref or an empty diff. Do not fail inside a subagent.

## Step 1. Collect the author's claims

Read the PR body, the commit messages, and the review-request text. Turn each claim into a row to
verify. A claim is anything the author asserts about behaviour, scope, or the reason for a change.

Verify by running something wherever you can. Reading the code is weaker evidence than executing it.
Grep for the callers. Run the spec. Check whether the pattern the author says is new already exists
on main.

Say in the body what you verified and how. That is the evidence for the verdict. A table helps when
there are several claims, and it is not required.

## Step 2. Fan out the axes

Run one subagent per axis. Never read the whole diff into the main context.

Run every applicable axis, even when the diff looks small or purely mechanical. Deciding early that a
change is "just" a rename is how the design-level findings get skipped.

Give every subagent the diff command, the commit list, and this instruction: report findings only,
under 400 words, and no prose summary.

Require every finding to carry five fields.

1. File and line.
2. One sentence naming the defect.
3. A concrete failure scenario. Specific inputs or state, then the wrong output or crash.
4. Confidence, as `confirmed` or `plausible`.
5. Whether main already does the same thing elsewhere.

Run these axes.

- **Correctness.** Bugs, wrong behaviour, missing cases, swallowed errors, unhandled state.
- **Claims.** Does the diff do what the author says it does? Report requirements that are missing or
  partial, behaviour nobody asked for, and claims the code contradicts. Quote the claim per finding.
- **Standards and smells.** Read `references/smell-baseline.md` and apply it. For language rules,
  invoke the matching standards skill if present, and do not restate its rules:
  `mercury-ruby-standards` for `.rb` and RSpec, `mercury-typescript-standards` for `.ts`, `.tsx`,
  `.js`, and `.css`, `mercury-vitest-standards` for Vitest specs.
- **Comments the diff adds.** See Step 2a.
- **Docs prose.** Run this axis only when the diff touches `.md` or `.mdx`. See Step 2b.

Report the axes separately. Do not merge them, because one axis passing can hide another failing.
Code can follow every standard and still implement the wrong thing.

### Step 2a. The comment audit

Sweep every comment the diff adds or changes. Look for four things.

1. **Historical narration.** A comment states the rule the code follows now. It does not narrate the
   change that produced it. Signature phrases to grep for: "now applies", "rather than", "under the
   old", "was harmless but", "used to".
2. **One fact, one home.** A fact restated in a second file becomes a pointer to the first.
3. **Verbosity.** A paragraph where one sentence carries the rule.
4. **A header that re-explains its section.** Prefer one rationale attached to the rule it justifies.

**The exception to rule 2 is load-bearing.** A fact that keeps two files in sync belongs in both.
Test it: could an editor of *this* file break the invariant without seeing the other file? Yes means
replicate the fact. No means make it a pointer.

**This audit is not cosmetic.** Reading the comments closely is how a missing code finding surfaces.
Treat any comment that does not match what the code does as a correctness lead.

### Step 2b. The docs prose pass

Review changed prose on two axes, not one.

First, style. Split unsplit seams at an em dash or a semicolon. Use active voice with a named actor.
Use a numbered list for three or more steps. Use one term per concept.

Second, accuracy. Check every claim the prose makes against the code. A rewritten justification is a
claim, not decoration. This axis finds factual errors, so never treat it as a style pass alone.

## Step 3. Triage

Reconcile what Step 2 returned. Do not re-run it.

**Trust each axis on its own finding.** The subagent already did that verification. Repeating it in
the main context defeats the fan-out and floods the context the fan-out protected.

**Own the recommendation.** That part is yours, not the subagent's. Check every proposed fix against
Step 5 before it becomes a comment. Watch for the retired symptom: a fix that resolves the visible
failure one level above where the cause lives.

**Two axes disagreeing is the one trigger for reading the code yourself.** When axes contradict each
other on the same lines, or one axis's fix would create another axis's finding, open that hunk and
make the call. Nothing else earns a re-read in the main context. Report the call you made, and raise
it when the hunk does not settle it.

Drop any finding with no concrete failure scenario. A finding that needs an artificial test setup to
happen is theoretical.

For each surviving finding, ask these five questions.

| Question | Real | Theoretical |
|---|---|---|
| Can this happen through actual usage? | yes | only via artificial test setup |
| Is this at a system boundary (user input, external API)? | yes | no, internal code with structural guarantees |
| Does a structural constraint prevent it? (OS modal, event loop, type system) | no | yes |
| Is this a public API / library surface? | yes | no, closed app, internal use |
| Does main already use the same pattern elsewhere without issues? | no | yes, not a new risk class |

Real findings become comments. Theoretical findings either get dropped or become an adjacent note
that says why. Defensive programming suits a system boundary. It does not suit internal code with a
structural guarantee.

The last row does the most work. "Main already does this" turns a finding into an adjacent note
rather than a defect in this diff.

**The circular finding trap.** If the fix for one finding would trigger the opposite finding, stop.
The loop itself signals that both findings are probably theoretical. Triage them rather than
oscillating.

**Calibrate the confidence you write.** State the observation and the reasoning. Do not dress
uncertainty as a ruling. A finding you are 60% on must read as 60%. Separate "this is wrong" from
"this looks off, check me".

**Why:** confident phrasing on a shaky finding costs the author a full context reload to disprove.
That is the same re-review cost the verdict rule exists to minimize.

## Step 4. Group the findings, then place them

**Collapse repeats into one comment.** Anchor it at the worst site. Name the other sites in the
discussion. Five history sites become one comment, not five.

**Every finding is an inline comment.** Anchor it to the line that shows the problem, because the
code is the context.

**Keep the body to three things.**

1. The verdict.
2. The evidence for it, from Step 1.
3. The count of comments.

Do not rank the findings in the body, and do not name a worst one. The inline comments carry that.

**A concern the user raised never gets answered in the body.** Answer it to the user, in the session.
Where it turned out to be a real defect, it becomes an ordinary inline comment, judged on its merits
like any other. Where it turned out to be nothing, the author has no use for the answer.

**The body never restates a finding.** Apply this test to every body sentence: could this be a
comment on a file? If yes, move it. A body sentence that reads as a finding is a finding. Praise is
a finding too, so anchor it on the file it praises.

**No aggregate hand-waving.** A sentence like "two of them are passes rather than defects" adds
confusion. Name the comments it refers to, or cut the sentence.

## Step 5. Write each comment

Use the Conventional Comments format.

```
<label> [decoration]: <subject>

<discussion>
```

The subject is one short line carrying the ask and nothing else. Reasoning, context, and next steps
go below the blank line.

**Why:** a label followed by one undifferentiated blob is the same comment with a prefix bolted on.

Labels, and the distinction each one carries:

- `issue:` A specific problem with the code. Blocking unless it says otherwise.
- `suggestion:` An improvement to the code. Name the replacement, not just the objection. Add
  `(blocking)` when the change is necessary rather than optional.
- `question:` A potential concern you genuinely do not know the answer to. Never a rhetorical device
  for an objection you have already formed.
- `nitpick:` Trivial and preference-based. Always non-blocking. Covers typos and polish.
- `thought:` An idea that came out of reading the diff, not a request. Always non-blocking. Keep it
  to a couple of lines.
- `chore:` Process rather than code. A changelog entry, a ticket link, a screenshot.
- `praise:` Worth keeping. No decoration.

Decorations: `(blocking)`, `(non-blocking)`, `(if-minor)`. The last one hands the judgement to the
author, who resolves it only if the fix stays small. Add a decoration only where the label leaves
severity open. Never stack two. Never decorate `nitpick:`, `thought:`, or `praise:`, because those
are non-blocking by definition.

Skip the `todo:` and `note:` labels from the specification. `todo:` collides with `TODO` comments in
code. `note:` is non-blocking by definition, so it is a decoration wearing a label's clothes.

### Describe the change. Do not write it.

This governs every label. Name the approach, the existing helper to reach for, the invariant to
preserve, or the case the current code misses. Never hand the author a drop-in patch or a
paste-ready snippet.

**Why:** a patch invites the author to accept it without reading it, so the code lands with nobody
understanding why. It also moves the design decision from the person who owns the file to the person
who skimmed it.

Use a code fragment only where the shape resists prose. A type signature, a single expression, or a
function name. Keep it short enough that pasting it would not compile on its own.

### Framing decides what the author does next

A change request is a prompt. Reviews get pasted into an agent as a matter of course, so the framing
picks the mode the reader drops into.

**Prescriptive framing produces execution mode.** A named fix gets good, well-scoped work. Its
ceiling is exactly your own insight. It cannot find what no comment points at. Its failure is subtle:
a correctly-scoped fix retires the only symptom of a defect, leaves the defect, and correctly reports
that as someone else's problem.

**Diagnostic framing produces design mode.** Naming the problem and leaving the fix open finds things
no comment pointed at. Its failure is a finding that is directionally real with a wrong
recommendation attached.

So: when the right fix is genuinely unclear, say so and leave it open. An open question is what
licenses a redesign. When a comment is prescriptive, know that it caps the result there.

### Volume is part of readability

Cut any comment that only restates the diff. Collapse repeats, per Step 4. Lead with the blocking
items. If more than about three findings block, say so at the top rather than making the reader
count.

## Step 6. Choose the verdict

The deciding question is "is a re-review needed?" It is not "are there issues to fix?"

**Approve, with notes,** when the issues are mechanical, scope judgements the author has better
context for, cleanup the author can execute unsupervised, naming opinions, or follow-up flags.

**Request Changes** when the issues are architecture or design problems, real security or performance
concerns, notable functionality gaps, non-trivial UI redesigns, or large rewrites. Also request
changes when you genuinely need to see the next iteration to confirm the fix landed.

Default to Approve when in doubt. Request Changes on mechanical cleanup imposes a re-review tax the
situation does not warrant.

## Step 7. Show, then post

Show the body and every comment. Wait for the go-ahead. Post once.

## Boundaries

- **Findings, never edits.** This skill diagnoses. `cleanup-pass` applies changes to code the user
  owns, and it keeps the post-merge re-scan that no review covers. Self-review runs this skill for
  the findings, then hands applying them to a separate explicit step.
- **Judgement, not mechanics.** Whether tests, lint, and typecheck pass belongs to
  `verification-before-completion`.
- **Language rules live in the standards skills.** Reference them. Never restate them.
