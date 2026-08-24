# Global Claude Instructions

## Always Capture the Why

When writing memory entries, documenting decisions, recommending deferrals, or noting trade-offs: always include the reasoning, not just the conclusion. Future context needs to know *why* a decision was made to judge whether it still applies — not just what was decided.

This applies to:
- Memory file entries (`**Why:**` lines)
- Inline code comments on non-obvious decisions
- PR descriptions and commit messages
- Any time I'm recording that something was deferred or chosen over an alternative

## Write in Simplified Technical English (flavored)

Default prose style for everything you write: review comments, explanations, commit messages,
status reports, docs, code comments, and your side of this conversation. The standard is
ASD-STE100 Simplified Technical English, in "flavored" mode — structural rules enforced,
vocabulary rules advisory.

**Lead with the verdict, then the reasoning.** Answer, recommendation, or bottom line in the first
two sentences. Evidence and caveats after. If I only read the opening, I should already have the
part I can act on. When there's genuinely no verdict (you asked me something, or we're
mid-brainstorm) lead with the question instead. Don't invent a verdict to satisfy the rule, and
don't claim there isn't one to avoid committing.

**Why:** a reply that reasons its way toward a recommendation makes me reconstruct the conclusion
myself, and a review comment that does it makes the author guess what you want changed.

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
English. Skip the aerospace register too: contractions are fine, and banning `-ing` forms buys a
formality I don't want.

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

## Comments in Code

**Code trumps a comment.** Before writing one, ask whether a rename, a restructure or a split makes
it unnecessary. Every comment you reach for is a signal that the code beneath it falls short. Often
the honest fix is the name. Sometimes it isn't, and the comment is right.

**Configuration gets a lighter bar.** A setting's wording is opaque on its own terms and its *why*
is rarely derivable from the value. Every rule here still applies, just less tightly.

**A comment states the rule the code follows now. It never narrates the change that produced it.**
Signature phrases that mean you're writing history: "now applies X rather than Y", "under the old
X", "was harmless but", "used to". The diff and the commit message carry the change.

**Why:** history in a comment ages badly. It reads as current guidance long after the "old" thing
is gone, and the next reader can't tell which half is still true. Keep the reason, drop the
chronology.

**One fact, one home.** State a fact once. A comment repeating what another comment owns shrinks to
a pointer at that owner.

**The exception is the sync comment.** When this code silently depends on code elsewhere — a wire
format, an ordering both ends assume, a constant another service parses — the comment goes at both
ends and each copy names the other. The test: could someone editing *this* code break the invariant
without ever opening the other one? Yes means write it twice. The further apart the two ends sit,
the more the second copy earns its place.

**It is the weakest way to keep two ends in sync, so look for a mechanism first.** A shared schema,
an imported constant, a contract test that fails on drift. A comment cannot fail. Reach for it when
nothing can enforce the link, which happens often across languages. Common does not make it the
default.

**An invariant earns a sync comment. A name does not.** The test is whether drift breaks something.
Rename a model on one side of an API boundary and nothing breaks. See Systems Name Themselves.

**Attach the rationale to the rule it justifies.** Don't write a section header that re-explains the
section beneath it.

## Naming

Filenames and module-level names. Naming inside code — variables, classes, methods — is a separate
rule this one does not loosen.

**Prefer one word.** Add a qualifier only when the short name would collide or mislead where it is
read. `mercury`, not `mercury-shared` — a folder's siblings already supply "shared".

**Why:** one word carries no separator, so it sidesteps the casing question. A second word forces a
choice that varies by repo, and a qualifier restating its own context is noise in every reference.

**When a file or directory mirrors an exported name, that ecosystem's transform wins and nothing
else here applies.** `UserProfile.tsx` for a default-exported React component, `user_profile.rb`
for the constant Zeitwerk resolves, `user_profile.py` for the module you import.

Otherwise the domain picks the separator.

- Becomes a URL, a slug or a wikilink target → **kebab**. Search engines split on hyphens and join
  on underscores, and slug generators followed.
- Otherwise → match whatever that directory already uses.
- Otherwise, with no de facto standard → **snake**. The older default, and the reason to reach for
  kebab is absent when nothing becomes a URL.

Spell each word out in full — `handler`, never `hdlr`. Adding a word and shortening one are
separate questions.

**No date prefixes.** Name a file after its subject. A second version is `pr2281-review-round2`,
not a new date. Keep a date only where the date *is* the identity — a daily note, a dated meeting.

**Why:** the filesystem tracks mtime and frontmatter makes a date queryable. The deciding reason is
linking: `[[pr2281-review]]` reads as a reference and `[[2026-07-31-eng63-tsc-gate-review]]` does
not.

### Systems Name Themselves

Every application owns its vocabulary — model names, table names, class hierarchies. Two systems
that exchange data are still two systems, so borrowing one side's names imports a design decision
made for someone else's problem.

The pull to copy a name across is strong, because both ends describe the same real thing and one
shared name is cheap and greppable. Resist it. A matching name implies a contract nobody wrote, and
the next reader treats it as one.

**The API boundary is the contract.** What crosses it is what the two ends owe each other.
Identifiers do not cross, so either side renames without forcing a migration on the other.

**A real contract goes in code.** Where a name genuinely is part of it — a discriminator value, a
serialized key, an enum another service parses — state it as a shared schema, a generated type or
an imported constant. That makes it an invariant, and an invariant is what earns the sync comment.

## Boy Scout Rule (calibrated)

Leave the files you touch better than you found them. When a change makes something redundant — a now-dead parameter, a vestigial wrapper, inert config, a no-longer-used export, an alias that just forwards — remove it in the same change. Before calling work done, re-scan the files you edited (and anything your change made redundant) for that adjacent cruft; treat it as part of verification, not an optional polish pass.

**This is cleanup of what you touched, not a license to refactor everything in sight.** It pairs with YAGNI / anti-over-engineering and never overrides them:
- Don't add abstractions, pull helpers "up" speculatively, or improve code you aren't otherwise touching.
- Don't expand scope to chase cruft. If a cleanup would balloon the change, note it as a follow-up (with the why) instead of doing it inline.
- Incidental sameness isn't a reason to abstract; a thin wrapper that only saves typing isn't worth keeping.

The recurring failure mode this guards against is leaving a half-done state after a change — and, after a merge that mixes someone else's work into files you refactored, assuming the cleanup "stuck" without re-checking. Re-scan; don't assume.

## Prefer Built-in Tools Over Bash

Reach for the file tools before the shell. Shell out only when no tool does the job.

- Read a file → `Read`, not `cat` / `head` / `tail` / `sed -n`.
- Search file contents → `Grep`, not `grep` / `rg` / `ag`.
- Find files by name or pattern → `Glob`, not `find` / `ls -R`.
- Change a file → `Edit` or `Write`, not `sed -i` / `awk` / a heredoc redirect.

**Why:** Bash is the call that stops for approval, so `cat foo.rb` costs a round trip that `Read`
does not. The tools also hand back line numbers, match context, and path filters that you would
otherwise rebuild out of flags.

Bash still owns everything with no tool equivalent: git, package managers, test runners, build
commands, and pipelines that transform output. A plain `ls` of one directory is fine. Once the
question becomes "which files match X", that's `Glob`.

## Delegate Code Search to Subagents

When getting bearings on scope in a large repo, dispatch a subagent (Explore / general-purpose) to do the grepping and file-reading and return only the distilled results. Do NOT run broad greps or bulk file Reads in the main context.

**Why:** Broad searches shove a lot into the main context window. I run long, wide-ranging conversations rather than one-off tasks, and want the main window kept low (target well below 20%) so we can keep going without summarization. Getting-bearings work otherwise eats 7–10% up front.

**How to apply:**
- Broad / uncertain search (naming conventions, "where does X live", multi-file sweeps) → subagent, results only.
- Single known lookup (file + rough line already known) → just Read the narrow slice directly; a subagent there is slower and buys nothing.
- Large PR diff review → don't read the whole diff into the main context. Before doing so, ask whether it's worth it; default to dispatching subagents (per-file or per-area) that return findings only, then I reason over the findings. Read specific hunks directly only when a finding needs closer judgment. Small diffs where reading it all is cheap → just read it.

## Picking a Basic Memory Scope

Agent memory lives in Basic Memory over MCP, split into six named scopes. Two hooks reach it for
you, both scoped to `personal`, `mercury`, and the repo scope matching cwd:

- `SessionStart` prints every note title in those scopes. **That index is the complete list, so a
  fact absent from it is absent from the store** — write it rather than search for it.
- `UserPromptSubmit` runs your message through hybrid search and injects the top hit per scope,
  with its path. Relevant notes arrive on their own, so don't reach for `search_notes` first.

**Reading a note whose path a hook printed is a plain file read.** Retrieval needed the tool.
Fetching does not.

**Writes still go through `write_note` or `edit_note`, never `Edit` or `Write`** — the file tools
leave the search index stale. Neither hook passes `project` for you, and a fact belonging to a
scope the hooks did not load still goes to that scope.

| Looking for | `project` |
|---|---|
| How I work, what I prefer, corrections I have given | `personal` |
| Team conventions, colleagues' handles and IDs, external repos | `mercury` |
| A codebase's state, its open threads, its repo-specific feedback | `talaria`, `thoth`, `psychopomp` |
| Dotfiles, shell, editor, terminal, agent config | `macdots` |

A fact about a person belongs in `personal` or `mercury` even when it surfaced inside a repo.

Each call reads one scope and never the others, so a question spanning a repo and a person takes
two searches. Searching the repo alone returns nothing and looks like an answer.

`~/Vault/README.md` is canonical for the rest — note format, naming, and the gotchas that fail
silently rather than erroring.

## `$HOME` Is a Git Work Tree

My dotfiles are a bare repo whose work tree is **all of `$HOME`**, driven by
`~/.local/bin/macdots` (also aliased `macdots`). Read the "Working in this
repo" section of `~/README.md` before running it.

- **Never** `macdots status -u` / `-uall` / `--untracked-files=...`, `add -A`,
  `add .` from `$HOME`, or `clean`. Each walks every file on the machine, which
  has locked it up badly enough to need a reboot. `status.showUntrackedFiles=no`
  plus an allowlist `~/.gitignore` keep the defaults safe; those flags defeat
  both. Add explicit paths, always — the repo is public.
- **To enumerate files under `$HOME`, reach for `Glob` or `ls`/`fd`, not git.**
  Git here is for the tracked set only — if the question is "what's in this
  directory", git is the wrong tool and the expensive one.
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

## Show the Change Before You Commit

Make the edit, show the changed passage, and stop. A commit or a push waits until I have read it.

One "commit this" authorizes one commit. It does not carry to the next edit, even when that edit
continues the same task. Ask again.

**Why:** my read is the only review a change gets. Committing in the same turn as the edit removes the
gap where I would catch a wrong call, and a pushed mistake costs a correction round rather than an
edit. This is the same split as the messages rule below — the action is authorized, the content is
not.

Batch related edits into one read rather than stopping after each one.

## Writing Messages That Go to Other People

**Invoke the `white-room:communique` skill before drafting anything that leaves this session for
a human other than me** — Slack, PR review bodies and comments, issue bodies, commit messages
others read. It owns the wording, the tagging, and writing for someone who has none of our context.

**Show me the actual wording before it goes out**, even when I've already said "post it" /
"send it" / "request changes". The instruction authorizes the action, not the wording.

**Why:** these go to real people, and once sent they re-ping and can't be cleanly unsent. The
gate stays resident rather than moving into the skill, because a missed invocation would send
the message anyway.

**`white-room:communique` and `white-room:review-changes` both live in `m4thayus/white-room`, not
in this repo.** Rename either one there and the invocation named here stops resolving, with nothing
to catch it.

### Reviewing code

**Invoke the `white-room:review-changes` skill before writing a single review comment.** It owns
the whole procedure, from resolving the target through to the Approve-versus-Request-Changes call,
including the [Conventional Comments](https://conventionalcomments.org/) format every comment has
to use. A review written without the skill is a review written without the format.

**Notes-only while a review is running.** Produce findings. Don't edit files, run renames, or
refactor, even when I say something imperative like "just do the crate shifting". An
imperative-sounding phrase during a review describes the work, or calls it mechanical. It isn't
authorization. Wait for "make the change" or a clear equivalent.

**Why this one rule and not the others:** a session can drift into reviewing without ever invoking a
skill, and the cost of missing it lands outside the session as commits on a colleague's branch.
Everything else in a review is recoverable before it's posted.
