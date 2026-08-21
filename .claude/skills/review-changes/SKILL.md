---
name: review-changes
description: Use when reviewing code changes. Covers a PR, a branch, a diff, changes since a commit, and your own work before you open a PR. Produces findings, inline comments in Conventional Comments format, and an Approve, Request Changes, or Comment verdict. It never edits the code, but it does check out the target, so run one review at a time in a working tree. Open a second worktree to review without stopping other work. Triggers on "review this PR", "review #1234", "review my branch", "review changes since main", "look at this PR", "request changes", "re-review", a later round on a PR you already reviewed, and a self-review before opening a PR.
---

# Review Changes

## What this skill owns

This skill owns the conduct of a review. That means five things.

1. Verifying what the author claims, independently.
2. Deciding which findings are real.
3. Deciding where each finding goes.
4. Writing each comment.
5. Choosing the verdict.

It does not own applying fixes.

**Name the three texts apart.** The author's text on the pull request is the **PR description**. The
top-level comment of the review you draft is the **review body**. The top-level comment of a review
an earlier round left is a **prior review body**. Never say "the body" unqualified, in either
artifact or in the session.

**The output is a draft, never a posted review.** Assemble the review body and every comment. Show
them. Wait for approval. Posting is the user's decision every time.

**The audience is the author, not the user running the review.** Write every line of the review body
and every comment for the person who wrote the code. Anything addressed to the user belongs in the
session instead, because the author has no use for it and no context for it.

## Four rules that bind the whole pass

**1. Notes-only. Produce findings. Do not edit.**

Run no Edit, no Write, and no `git mv` during a review. An imperative-sounding phrase during a review
describes the work. It does not authorize the work. "Just do the crate shifting" characterizes a
change as mechanical. Only "make the change", or a clear equivalent, authorizes one.

Detect whose branch it is before any edit. Run `git log <base>..HEAD --format='%an'`. If any name
other than the user's appears, the branch is someone else's. Stay in review mode until told
otherwise. A branch the user pushed one commit to is still not the user's branch.

Self-review does not relax this rule on its own. Produce the findings first. Applying them is a
separate step the user asks for.

**Why:** editing another person's branch steps on their work. The value of a review is the
conclusions the user can relay, not commits nobody asked for.

**2. Post once.**

Accumulate findings in a scratch file under `/tmp`, never inside the work tree. Never post per file
as the walk proceeds.
Post the whole review in one pass at the end.

One pass is not one call. A re-raise or a retraction is a reply on its own thread, per Step 4, and no
thread reply can ride inside a review submission. Step 7 carries the order.

**Why:** piecemeal comments fragment the review. They re-ping the author on every push. They lose
the big-picture framing that makes one considered pass readable.

One exception: a batch of self-contained non-blocking cleanup the author can clear in parallel, such
as a set of type errors. Post that as a standalone comment. Nothing else qualifies.

**3. Show the wording before it goes out. Every time.**

Draft the review body and every comment. Show them inline. Ask before any call that writes to the
PR, `gh pr review`, `gh pr comment` and `gh api` with a POST or a PATCH alike. This applies to
follow-up thread replies too. "Post it" authorizes the action, not the wording.

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
4. **A prior round needs a call you do not own.** The author pushed back and did not change the
   code, or another reviewer contradicts one of your prior comments. See the routing table in
   Step 3.
5. **The diff introduces a pattern the repo has no prior art for, and no rule covers it.** Whether
   the team agreed to it is not answerable from the repo. See Step 3.
6. **This is the third round on the same PR.** The rounds have stopped being about mechanics. See
   Step 6.

**Report the conflicts you did settle.** Give each cross-axis contradiction one line in the session,
with the call you made. Never resolve one silently. Keep it brief and let the user ask for the detail.

**Report the prior threads you dropped.** Give each silently-ignored thread the label rules dropped
one line in the session. The author has no use for it, and the user may disagree with the drop.

A finding that flips the verdict is not an escalation. Recommend the verdict and let the user override
it.

## Write every artifact in Simplified Technical English

`references/style.md` carries the rules for everything this skill produces. Read it before you write
the review body or a comment.

Which artifact takes which mode.

- **Strict.** A comment subject line, and every prompt you send a subagent. A wrong reading there
  costs the author a round.
- **Flavored.** The discussion under a subject, and the review body. Contractions and some range read
  better there.

## Step 0. Resolve the target

Resolve the target before reading any code. Use the first of these that applies.

1. An explicit argument. A PR number, `owner/repo#N`, a URL, a branch name, a commit or tag, or `.`
   for the current branch.
2. No argument. Run `gh pr view --json number,title,body,headRefName,author`.
3. No PR for the branch. Diff against the merge-base, and say that is what you are reviewing.
4. Ambiguous, or not a git repo. Ask. Do not guess a target.

**Check out the target before anything else reads it.** The axes verify by executing, not by reading
alone. Checks runs the suites the repo declares. Standards runs a built-in against the edge cases.
Claims runs the one case behind an author's assertion. All of it reads the working tree, so the tree
has to hold the code under review.

**A dirty tree stops the review.** Name what is uncommitted and ask. Never stash, and never check
out over uncommitted work. This holds for a self-review too. Uncommitted work is not reviewable,
because no other reviewer can fetch it and no CI run covers it.

**Where the target is not already HEAD, fetch it and check it out.** Name the ref you moved to in
the session, so the user sees the tree move.

Confirm the base ref resolves and the diff is not empty. Capture one diff command and reuse it:
`git diff <base>...HEAD`. Use three dots so the comparison runs against the merge-base. Capture the
commit list with `git log <base>..HEAD --oneline`.

Fail here on a bad ref or an empty diff. Do not fail inside a subagent.

**Then check whether the diff depends on a sibling repo.** A PR in a multi-repo series frequently
reads code that lives in another repo's unmerged branch. Where it does, find that PR, fetch its head,
and record the exact SHA. Carry the SHA into every subagent prompt, per Step 2.

The sibling's default branch is the wrong source, because the change the diff depends on has not
landed there yet. A finding read off the default branch comes back confirmed and wrong.

**Then check for prior rounds.** Review history changes the axis set, so detect it here rather than
part-way through.

Dispatch a Haiku subagent for the fetch. The thread JSON grows with the review history, and none of
it belongs in this context.

> Run both commands for pull request <n> in <owner>/<repo>.
>
> 1. `gh pr view <n> --json reviews` for the prior review bodies.
> 2. `gh api repos/{owner}/{repo}/pulls/<n>/comments` for every inline thread.
>
> Write both results to the `/tmp` scratch file at <path>. Then report three things and nothing
> else: whether any prior review exists, how many inline threads there are, and the path you wrote.

Run `gh api user --jq .login` yourself, because one line of output costs more to delegate than to
fetch. The Prior Round axis needs it to tell your prior comments from another reviewer's.

Say in the session whether this is a first pass or a re-review.

## Step 1. Read the PR: the claims, then the metadata

**The claims.** Read the PR description, the commit messages, and the review-request text. Turn each
claim into a row to verify. A claim is anything the author asserts about behavior, scope, or the
reason for a change.

Verify by running something wherever you can. Reading the code is weaker evidence than executing it.
Grep for the callers. Run the spec. Check whether the pattern the author says is new already exists
on main.

Say in the review body which claims you verified and how. That is the evidence for the verdict, and
it covers the claims only. A table helps when there are several claims, and it is not required.

**The suites are not a claim.** "Specs pass", "lint is clean", and "typecheck passes" get no
verification row. The Checks axis runs them anyway, per Step 2, and only a failure reaches the
review.

**The metadata.** Three questions about the pull request itself, not about the diff.

1. Does the PR description still describe the diff? A description written against an earlier revision
   is common, and the author cannot see the drift from inside the branch.
2. Is a label the repo expects missing? Run `gh label list` for what exists and
   `gh pr view --json labels` for what is set. A blast-radius or a notable-change label is the common
   miss, because each is a judgment call nobody makes at open time.
3. Has a label gone stale? Nobody revisits a label after the PR opens. A `chore` or a `refactor` that
   grew into a behavior change now needs the label a feature takes.

None of the three anchors to a line of code, so all three belong in the review body. See Step 4.

## Step 2. Dispatch the axes

One axis per subagent, so no axis sees another's reasoning. Deciding early that a change is "just" a
rename is how the design-level findings get skipped.

**Set the model on every dispatch.** An axis inherits the session model where the dispatch names
none, so a whole review runs on Opus. Split it by what the axis needs.

- **Opus.** Correctness, Claims, Standards, and Prior Round. Each one rules on unfamiliar code, and a
  weaker model there returns a confident wrong finding.
- **Sonnet.** Precedent, Comments, and Prose. Each one works from an explicit brief against bounded
  input, so the brief carries the reasoning rather than the model.
- **Haiku.** Checks. It runs the commands the repo declares and reports what came back, so it judges
  nothing.

**Every subagent prompt carries these parts.**

1. The diff command and the commit list from Step 0.
2. The absolute path to every reference file the axis names, resolved from this skill's base
   directory. A subagent never sees this file, so a relative path reaches nothing.
3. The axis brief below, verbatim.
4. The finding contract below. Precedent and Prior Round are the exceptions, because each brief
   carries its own output shape.
5. **Where Step 0 found a sibling-repo dependency:** the repo, the PR number, and the SHA to read.
   State that the default branch is not the source.

**The finding contract.** Give every subagent these words: report findings only, under 400 words,
and no prose summary. Every finding carries five fields.

1. File and line.
2. One sentence naming the defect.
3. A concrete failure scenario. Specific inputs or state, then the wrong output or crash.
4. Confidence, as `confirmed` or `plausible`.
5. Whether main already does the same thing elsewhere.

**A clean axis reports an explicit negative.** Require the words its brief names: `no findings` for
most, `no failures` for Checks. Silence and a clean pass read alike in the main context, so an axis
that returned nothing at all has to be dispatched again.

### Pick the axis set

Read the changed paths first: `git diff --name-only <base>...HEAD`. The paths pick the set.

- **Prose-only diff**, where every changed path is `.md` or `.mdx`. Dispatch **Claims**, **Prose**,
  and **Checks**. A markdown linter and a spell check are checks. Nothing else, because the diff
  holds no code to be wrong and no comment to audit.
- **Any other diff.** Dispatch **Correctness**, **Claims**, **Standards**, **Precedent**,
  **Comments**, and **Checks**. Add **Prose** where the diff also touches `.md` or `.mdx`.

Add **Prior Round** to either set where Step 0 found prior review rounds.

Dispatch every axis the set names, including one whose subject looks thin. An axis with nothing to
say costs one `no findings` line.

### The axis briefs

**Correctness.**

> Report bugs, wrong behavior, missing cases, swallowed errors, and unhandled state in this diff.
> Read the code around a changed hunk before you judge the hunk.

**Claims.** Paste the claims you collected in Step 1.

> Report requirements in these claims that the diff misses or half-implements, behavior nobody asked
> for, and claims the code contradicts. Quote the claim in each finding. Where a claim and the code
> disagree, say which of the two is wrong.

**Standards.** Pass `references/smells.md`.

> Read the diff first as someone fluent in its language and its framework. Ask whether the standard
> library, the framework, or a dependency the repo already loads does what this code hand-rolls.
> Report a hand-rolled equivalent of a built-in, a house pattern the code sidesteps, and a call whose
> name overstates what it does.
>
> Verify the equivalence before you report it. Run both against the edge cases, and name the cases
> you ran. A built-in that is nearly equivalent is a different finding from one that is equivalent.
>
> No reference lists this, because fluency is the whole documented surface of a language and its
> framework rather than a rule set.
>
> Then apply the smells reference to this diff. Invoke the matching standards skill for the languages
> the diff touches, and do not restate its rules: `mercury-ruby-standards` for `.rb` and RSpec,
> `mercury-typescript-standards` for `.ts`, `.tsx`, `.js`, and `.css`, `mercury-vitest-standards` for
> Vitest specs.

**Precedent.**

> Report what the repo already does, and what it has never done. Run two sweeps.
>
> 1. **No prior art.** What does this diff introduce that the repo has nothing like? A file kind, a
>    directory, a layer, a naming shape, an export pattern, a dependency.
> 2. **Prior art.** What does this diff do that the repo already does elsewhere? Name the other
>    sites.
>
> A search that returns only the new file is the finding.
>
> Report prior art as fact, and do not rule on it. Prior art makes a thing precedented. It does not
> make the thing right, and its absence does not make a thing wrong.
>
> This axis reports observations rather than defects, so the finding contract does not apply. Each
> row carries three fields.
>
> 1. The thing, as the diff introduces it or repeats it.
> 2. The search you ran, so the reader can judge it.
> 3. What the search returned.

**Comments.** Pass `references/style.md`.

> Sweep every comment this diff adds or changes. Report six things.
>
> 1. **A comment the code should have made unnecessary.** Code trumps a comment. Where a rename, a
>    restructure, or a split would remove the need for the comment, report that change instead. Often
>    the honest fix is the name.
> 2. **Historical narration.** A comment states the rule the code follows now. It does not narrate
>    the change that produced it. Signature phrases to grep for: "now applies", "under the old",
>    "was harmless but", "used to".
> 3. **One fact, one home.** A comment restating what another comment already owns should be a
>    pointer to that owner instead.
> 4. **Verbosity.** A paragraph where one sentence carries the rule.
> 5. **A header that re-explains its section.** Prefer one rationale attached to the rule it
>    justifies.
> 6. **Style.** Apply the style reference in flavored mode. A changed comment takes the same
>    structural rules as a review comment, because the next maintainer reads it the same way.
>
> Configuration takes a lighter pass. A setting's wording is frequently opaque on its own terms, and
> its *why* is rarely derivable from the value, so a comment there earns its place more easily. Still
> read it. Report one that is genuinely redundant or bloated, and do not go hunting for one.
>
> The exception to one fact, one home is the sync comment. Sometimes this code silently depends on
> code elsewhere: a wire format, a shared schema, an ordering both ends assume, a constant another
> service parses. Then the comment belongs at both ends, and each copy names the other. The other
> end may be another file, another package, or another repo. Test it: could someone editing *this*
> code break the invariant without ever opening the other one? Yes means replicate the fact. No
> means make it a pointer.
>
> This audit is not cosmetic. Reading the comments closely is how a missing code finding surfaces.
> Treat any comment that does not match what the code does as a correctness lead.

**Prose.** Pass `references/style.md`.

> Check the changed prose two ways, not one.
>
> First, style. Check the changed prose against the style reference, and name the mode each changed
> file falls under. A violation in a file that sets the rule itself is the strongest form of this
> finding.
>
> Second, accuracy. Check every claim the prose makes against the code. A rewritten justification is
> a claim, not decoration. This check finds factual errors, so never treat the pass as style alone.

**Checks.** Pass the pull request number.

> Run every kind of check this repo declares, not the one nearest the diff: the spec suite, the
> linter, the typechecker, and the build. Narrowing a suite to the paths the diff touches is fine.
> Skipping a whole kind of check is not.
>
> Take each command from the repo, not from habit. The CI workflow, the git hooks and the package
> scripts already declare how this project runs its checks. An invocation you compose yourself can
> cover less ground than the declared one and still exit zero, which reads as green over the gap.
>
> Where the repo declares several commands for one kind of check, run all of them. A split
> configuration usually exists because one target excludes what another covers.
>
> Run `gh pr checks <n>` as well. The local run and the CI status are both checks, and neither
> replaces the other. A local run catches a check the CI config never runs. CI catches a failure in
> an environment you do not have.
>
> This axis reports process results rather than defects, so the finding contract does not apply.
> Report a failure only, locally or on CI, and give each one three fields.
>
> 1. The command, as the repo declares it.
> 2. The failing target, named closely enough to comment on the line.
> 3. Whether it failed locally, on CI, or both.
>
> Report any check you could not run, and name the setup it needed.

**Prior Round.** Dispatch only where Step 0 found prior rounds. Pass the `/tmp` file holding the
prior review bodies and the threads, and pass your own login.

> Report one disposition for every prior thread. Run three checks.
>
> 1. **Every reply that claims a fix.** Verify it against the current code. A reply is a claim, and a
>    claimed fix the code does not show is the strongest finding a later round produces.
> 2. **Every prior comment of ours.** Ask whether it is still correct, given what the diff now shows.
>    A prior comment that was wrong needs a retraction, and no other axis looks for one.
> 3. **Every other reviewer's position.** Report it as data. Do not adjudicate it, because the user
>    decides where two reviewers disagree.
>
> Read every thread. Do not sample.
>
> This axis reports dispositions rather than defects, so the finding contract does not apply. Each
> row carries four fields.
>
> 1. The thread.
> 2. How hard the prior comment asked: **blocking**, **optional**, or **trivial**. Judge it from the
>    wording where the comment carries no marker, because reviewers write in their own conventions.
> 3. The disposition, from the list below.
> 4. The evidence.
>
> The dispositions.
>
> - Fixed as asked.
> - Claimed fixed, and the code does not show it.
> - Fixed differently, and it works.
> - Fixed differently, and it breaks something else.
> - Our prior comment was wrong.
> - The author pushed back and did not change it.
> - Another reviewer contradicts our prior comment.
> - Another reviewer agrees with our prior comment.
> - Ignored in silence, meaning no reply and no change.
>
> Say what each disposition rests on. Where an alternative fix reads better than the one we asked
> for, say so. Where two dispositions both fit, name both and say which you lean to.

Report the axes separately. Do not merge them, because one axis passing can hide another failing.
Code can follow every standard and still implement the wrong thing.

## Step 3. Triage

Reconcile what Step 2 returned. Do not re-run it.

**Trust each axis on its own finding.** The subagent that ran the axis already did that
verification. Repeating it in the main context refills the context that one axis per subagent kept
clear.

**Own the recommendation.** That part is yours, not the subagent's. Check every proposed fix against
Step 5 before it becomes a comment. Watch for the retired symptom: a fix that resolves the visible
failure one level above where the cause lives.

**Two axes disagreeing is the one trigger for reading the code yourself.** When axes contradict each
other on the same lines, or one axis's fix would create another axis's finding, open that hunk and
make the call. Nothing else earns a re-read in the main context. Report the call you made, and raise
it when the hunk does not settle it.

Drop any finding with no concrete failure scenario. A finding that needs an artificial test setup to
happen is theoretical.

**Precedent, Prior Round and Checks are exempt from that rule, for two different reasons.** An
observation and a disposition are not defects, so no failure scenario attaches to either. A check
failure is the opposite case. It already happened, so the run is its failure scenario and nothing
about it is theoretical. Route all three below.

For each surviving finding, ask these four questions.

| Question | Real | Theoretical |
|---|---|---|
| Can this happen through actual usage? | yes | only via artificial test setup |
| Is this at a system boundary (user input, external API)? | yes | no, internal code with structural guarantees |
| Does a structural constraint prevent it? (OS modal, event loop, type system) | no | yes |
| Is this a public API / library surface? | yes | no, closed app, internal use |

Real findings become comments. Drop a theoretical finding, or turn it into an adjacent note that says
why it is theoretical. Defensive programming suits a system boundary. It does not suit internal code with a
structural guarantee.

**The circular finding trap.** If the fix for one finding would trigger the opposite finding, stop.
The loop itself signals that both findings are probably theoretical. Triage them rather than
oscillating.

**Use what Precedent reported.** It decides who owns a fix, and what a finding covers. It never
decides whether a finding is real, or how severe it is.

| What Precedent found | Destination |
|---|---|
| No prior art, and no rule against it | session, because "was this agreed?" is not answerable from the repo |
| No prior art, and a rule against it | inline comment, citing the rule |
| Prior art, and an axis flagged it | inline comment, naming where else the pattern appears |

A bug main also has is the same bug. Prior art changes what the comment says, not what it asks for.
Say that the pattern predates this diff, and that the fix reaches past it.

Ask what a finding actually is before you reach for prior art. A finding rewritten around the points
that survive it is frequently the wrong finding.

**Route the Checks rows.** Every failure is blocking, and it goes near the top of the review body.
Where the failing target points at a line, add an inline comment for the detail as well. Where the
axis could not run a check, say so in the session, and name the CI result you fell back on.

**Route the Prior Round rows.** The axis reports what it saw, and it does not choose a destination.

| Disposition | Destination |
|---|---|
| Fixed as asked | nowhere |
| Claimed fixed, and the code does not show it | re-raise |
| Fixed differently, and it works | nowhere, unless the alternative is worth naming |
| Fixed differently, and it breaks something else | re-raise |
| Our prior comment was wrong | retract |
| The author pushed back and did not change it | session |
| Another reviewer contradicts our prior comment | session |
| Another reviewer agrees with our prior comment | nowhere |
| Ignored in silence | how hard we asked decides, below |

**Ignored in silence.** How hard the prior comment asked decides. A non-blocking ask left the change
optional, so re-raising it removes the option.

| How hard we asked | The label, where the comment was ours | Destination |
|---|---|---|
| Blocking | `issue:`, `suggestion: (blocking)` | re-raise |
| Optional | `suggestion:` | one line, non-blocking |
| Trivial | `suggestion: (if-minor)`, `nitpick:`, `thought:` | drop, and note it in the session |

**Reconcile this round against the other reviewers.** Prior Round reported their positions, so check
every finding you are keeping against them. A finding that contradicts a position goes to the
session, not the draft. A finding another reviewer already made gets cut, or shrinks to one line
agreeing with theirs.

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

**An anchor has to sit inside a diff hunk.** GitHub rejects every other line, so check the hunk
before you choose.

**Anchor to the line that names the subject.** Where the declaration sits outside every hunk, pick an
in-hunk line that references it and name the declaration in prose. A comment about a type that
anchors to some unrelated field reads as a comment about that field.

Prefer one line to a range. GitHub renders a range comment at its last line, and the line that names
the subject can sit outside the preview shown there.

Naming a line in prose changes how the comment is written, so settle the anchor here rather than
while assembling the payload.

**A claim the code contradicts has two possible defects. Place it by which one.** Where the code is
wrong, that is an ordinary inline comment. Where the code is right and the claim is wrong, the defect
is a sentence in the description, so it goes in the review body with the metadata findings.

Lead that one with the claim. Quote it, say what verification found, and name the fix as correcting
the description. Code detail goes underneath as evidence.

**Why:** leading with the code analysis reads as "your change is broken". The author defends an
implementation that was never in question, and a one-sentence documentation fix costs a round-trip.

**A re-raise or a retraction is a reply on the original thread.** The thread carries the history a
fresh comment would orphan. Where the thread takes no reply, because it is resolved or outdated or
the prior comment was a prior review body, post one PR-level comment instead and link the original.

**The review body has three fixed parts and two conditional ones.**

1. The verdict.
2. **Where a check from Step 2 failed:** one line per failing check, labelled `issue:` and blocking.
   Name the check and what it reports. A failing suite is a fact about the whole PR, so it never
   sits only in an inline comment. The location detail is what the inline comment carries.
3. The evidence for the verdict, from Step 1.
4. The count of inline comments, `praise:` and `thought:` excluded. Where that count is zero, say
   you read the whole diff and found nothing to change, and name every axis that came back with no
   findings.
5. **Where Step 1's metadata pass found something:** each metadata finding, one line each, labelled
   from the Step 5 list.

Do not rank the axis findings in the review body, and do not name a worst one. The inline comments
carry that.

**A concern the user raised never gets answered in the review body.** Answer it to the user, in the
session. Where it turned out to be a real defect, it becomes an ordinary inline comment, judged on
its merits like any other. Where it turned out to be nothing, the author has no use for the answer.

**The review body never restates a finding.** Apply this test to every sentence in it: could this be
a comment on a file? If yes, move it. A sentence that reads as a finding is a finding. Praise is a
finding too, so anchor it on the file it praises. A metadata finding has no file to anchor to, which
is why the review body is where it goes.

**No aggregate hand-waving.** A sentence like "two of them are passes rather than defects" adds
confusion. Name the comments it refers to, or cut the sentence.

## Step 5. Write each comment

Use the [Conventional Comments](https://conventionalcomments.org/) format.

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

**Why:** the label does the work the prose was failing at. Unlabelled, the author reverse-engineers
severity from tone, so a hedge reads as optional and a plain statement reads as a demand. Naming the
stance lets the sentence stay plain.

Decorations: `(blocking)`, `(non-blocking)`, `(if-minor)`. The last one hands the judgment to the
author, who resolves it only if the fix stays small. Add a decoration only where the label leaves
severity open. Never stack two. Never decorate `nitpick:`, `thought:`, or `praise:`, because those
are non-blocking by definition.

**A retraction takes no label.** It is a reply that names what it retracts and why. Do not restate
the original comment, because the thread above it already carries the text.

**Address a person by `@login` once in a thread reply or a standalone PR comment.** This covers a
reply to the author, a reply to another reviewer, and a retraction. Use the plain name after the
first `@login` in the same comment, never instead of it.

**Why:** GitHub notifies on the mention, not on the name. A reply that only writes "Sam" reaches
nobody who is not already watching the thread, and a re-raise the author never sees is a re-raise
that costs a round.

**Never `@`-mention anyone in a new inline comment.** Name the person plainly where the sentence
needs them.

**Why:** submitting the review already notifies the author, and every inline comment is addressed to
them by default. A mention on each one adds a duplicate notification and reads as shouting.

Skip the `todo:` and `note:` labels from the specification. `todo:` collides with `TODO` comments in
code, which carry a different meaning to the team. `note:` is non-blocking by definition, so it is a
decoration wearing a label's clothes.

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
ceiling is exactly your own insight. It cannot find what no comment points at. Its failure is subtle.
A correctly-scoped fix retires the only symptom of a defect. The defect stays, and the fixer correctly
reports it as out of scope.

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

The deciding question is "do I have to see the next iteration myself?" It is not "are there issues
to fix?" and it is not "how bad is the worst finding?"

A blocking inline comment already holds the author accountable. It marks a finding fix-before-merge
without asking to see the fix. Severity picks the comment label. It does not pick the verdict.

**Why:** the team honours a blocking comment. Request Changes on top of one buys no extra guarantee,
and it costs the author a round-trip.

### The ladder

Each rung asks more of the author than the one below it. Take the lowest rung that holds.

**1. Approve, clean.** Nothing in the review asks the author for anything, the review body included.
Only `praise:` and `thought:` belong here, because neither carries a request. A `nitpick:` does carry
one, even though it never blocks. The axis list in the review body is what separates a clean approval
from a shallow one, so Step 4 makes it the third part.

**2. Approve, with notes.** The review asks for things, and none of them needs you to see the result.
Blocking comments live on this rung. A review that found real problems with known fixes lands here,
and that is the normal shape.

**3. Request Changes.** The next iteration is the thing you need to see. One of these has to hold.

- A check from Step 2 fails. Whether the suite goes green is a fact only the next run shows.
- The fix has no agreed shape. You disputed the approach, so what lands is not predictable.
- A reply cannot confirm the fix. Only the diff shows it.

Your own prior blocking finding, still unfixed and unanswered, holds this rung on the same logic. You
asked once already, so the next iteration is still the thing you need to see.

Then ask what round this is. The bar rises steeply, not by one step each time.

| Round | What this rung needs |
|-------|----------------------|
| 1 | A case holds. Ordinary, and cheap. |
| 2 | A case holds, and one sentence names what the next iteration settles. |
| 3 | Nothing qualifies. Stop, and raise it with the user. |

**Why:** each round costs a full re-read from someone who already read the diff. A PR that reaches a
third round is no longer arguing about mechanics. It is arguing about design, the two sides are
flip-flopping, and a comment thread will not settle it. Name a venue that can: a call, a design
discussion, a conversation with the author. Rung 4 can carry that ask, or post no review and take it
up directly.

**4. Comment.** A fix is not what you want. A change can be soundly built and still be the wrong
change. Approving endorses it, and Request Changes asks for a next iteration you cannot describe,
because the open question is whether to do this at all.

Raise it with the user before you draft anything. A wrong premise or a wrong scope is a conversation,
not a review artifact.

### Another reviewer's open finding is data

The reviewer who raised a finding owns it. First come, first served. They decide whether it gates,
and their decision stands whichever way it went. Report it, per the Prior Round axis.

It tells you nothing about your own verdict, in either direction. A finding they gated on is not a
reason for you to gate. One they approved over is not a reason for you to let it go. You can agree
with their point, say so, and still need no round-trip of your own.

Gating on their finding also takes it out of their hands. A Request Changes blocks the merge by
itself, so it overrides the Approve they gave with the finding open.

### Name no verdict until every axis reports

Wait for all dispatched axes, even for a provisional call in the session. A late axis reverses an
early verdict, and the reversal reads as indecision rather than as new evidence.

Default to the lowest rung that holds. Rung 3 levies a re-review tax. Say what the tax buys, or do
not levy it.

## Step 7. Show, then post

Show the review body and every comment. Wait for the go-ahead. That go-ahead covers the wording. The
payload gets its own check below.

**Head each comment with a link, not a bare path.**

```
[app/javascript/src/viewers/types/base.ts:45](https://github.com/<owner>/<repo>/blob/<sha>/app/javascript/src/viewers/types/base.ts#L45)
```

Pin `<sha>` to the head commit so the link cannot drift while the user reads. The user opens the line
in one click, which is what they do anyway to judge a comment.

**Re-fetch immediately before `gh pr review`.** Nothing pauses the PR while you review it, and
nothing pauses it while you wait for the go-ahead. A long pass makes the Step 0 snapshot stale.
Re-run the Step 0 prior-round commands, and add
`gh pr view <n> --json state,reviewDecision,headRefOid`.

Reconcile the result against the drafted findings.

1. Another reviewer already made a point you drafted. Drop your comment, and reply on their thread
   instead.
2. `headRefOid` moved. Always say so in the session, and name what moved. Run
   `git log <old-oid>..<new-oid> --oneline`, then `git diff <old-oid>..<new-oid>` over the files your
   findings cite. Judge by the cited lines, not by the file list. A merge from the base branch churns
   whole files while leaving every finding intact.
   - Your cited lines are untouched. Say so, and post.
   - The author already fixed a finding you drafted. Drop that one, and post the rest.
   - Neither case above applies. Stop, and let the user choose between a full Step 0 round, a
     re-check of the touched findings only, and posting as drafted.
3. The PR merged or closed. Stop, and raise it with the user.

Show the revised set and get a fresh go-ahead when anything changed. Post once.

### Post the thread replies first, then the review

Each thread reply needs its own call, and none of them can be part of the review submission. Post
them first. The review body counts the inline comments, re-raises included, so a body that lands
ahead of its replies points the author at something they cannot find.

`gh pr review` takes a body and nothing else, so it cannot post an anchored inline comment. Reach for
`gh api` instead.

1. One reply per prior thread:
   `POST /repos/{owner}/{repo}/pulls/{n}/comments/{comment_id}/replies`.
2. The review, body and every inline comment in one call:
   `POST /repos/{owner}/{repo}/pulls/{n}/reviews`, with `event`, `body`, and a `comments` array of
   `path`, `line`, optional `start_line`, `side`, and `body`.

Pass the payload as a file with `--input`, because a comment body carries backticks and pipes that do
not survive a shell argument. Write that file from the `/tmp` scratch file.

### Read the payload back as raw text

Assemble the file, then print it back through the shell and show that output.

```sh
jq -r '"--- body ---", .body,
       (.comments[] | "--- \(.path) \(.start_line // .line):\(.line) ---", .body)' <payload>
```

Those bytes are what the author reads, anchors included. The final go-ahead attaches to them, not to
the draft earlier in the session.

**Why through the shell.** Your message text renders as markdown. Shell output does not. Backticks
that made a subject line legible in chat vanish into a code span there and print literally here.
GitHub renders them the way chat did, as one code span that swallows the label. Re-printing the draft
in a message shows you the same rendering that hid the problem the first time.

This checks fidelity, not correctness. It confirms that what ships is what the user approved, and it
catches a dropped comment or a wrong anchor. It says nothing about whether a finding is right.

### Shape each write as one call

One endpoint per Bash call, with an absolute path to the payload file.

**When a write is denied, stop.** Do not reshape the command and retry, because retrying a denied
write is the thing the denial asks you not to do. Show the user the exact command and let them run
it. Nothing is lost: the wording is approved and the payload is already read back.

