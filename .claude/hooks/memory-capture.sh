#!/bin/bash
# UserPromptSubmit hook: automatic capture. Asks the model, on every turn, whether the turn taught it
# a durable fact — and to write it if so.
#
# The question arrives as context before the model composes the reply, which is where the built-in
# auto memory's equivalent sits. Stop can also reach the model, by exit 2, but only after the turn it
# asks about has already ended.
#
# There is no gate, because a gate can only count turns and worth is a property of content. The bar
# in the text below is the whole filter. A turn threshold also silently skipped every short session:
# measured across 13 sessions, 5 never reached turn 6.

set -u
. "$HOME/.claude/hooks/memory-scope.sh"

LOG="$HOME/.claude/.memory-capture.log"

# Turns are the denominator for the write count. Zero writes has three causes that look identical
# from outside: the hook never ran, no session got far enough, or the bar rejects everything.
# Sessions and turns beside writes separate all three.
if [ "${1:-}" = --stats ]; then
  python3 - "$LOG" <<'READOUT'
import collections, glob, json, os, sys

sessions, turns = collections.defaultdict(set), collections.Counter()
try:
    with open(sys.argv[1]) as fh:
        for line in fh:
            # Lines a gated version of this hook wrote count neither sessions nor turns. They stay on
            # disk as the record of what the gate did, and they measured fires rather than turns.
            fields = line.split()
            if len(fields) < 3 or fields[1] != "turn":
                continue
            turns[fields[0][:10]] += 1
            sessions[fields[0][:10]].add(fields[2])
except OSError:
    pass

WRITES = {"write_note", "edit_note", "delete_note", "move_note"}
writes = collections.Counter()
for path in glob.glob(os.path.expanduser("~/.claude/projects/*/*.jsonl")):
    # The migration built the store by hand from its own directory. That is maintenance, not signal.
    if os.path.basename(os.path.dirname(path)) == "-Users-matt--claude":
        continue
    with open(path, errors="replace") as fh:
        for line in fh:
            try:
                record = json.loads(line)
            except ValueError:
                continue
            for block in (record.get("message") or {}).get("content") or []:
                if not isinstance(block, dict) or block.get("type") != "tool_use":
                    continue
                name = block.get("name", "")
                if name.startswith("mcp__basic-memory__") and name.split("__")[-1] in WRITES:
                    writes[(record.get("timestamp") or "?")[:10]] += 1

print(f"{'date':12}{'sessions':>10}{'turns':>7}{'writes':>8}")
for day in sorted(set(sessions) | set(turns) | set(writes)):
    print(f"{day:12}{len(sessions[day]):>10}{turns[day]:>7}{writes[day]:>8}")
print(f"{'total':12}{len(set().union(*sessions.values()) if sessions else set()):>10}"
      f"{sum(turns.values()):>7}{sum(writes.values()):>8}")
READOUT
  exit 0
fi

IN=$(cat)
session=$(printf '%s' "$IN" | jq -r '.session_id // "nosession"')
HOOK_CWD=$(printf '%s' "$IN" | jq -r '.cwd // ""')
[ -d "$MEM" ] || exit 0

printf '%s turn %s scopes="%s"\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$session" "$(scopes_here)" >>"$LOG"

# The bar splits by scope, and the split is stated generically so a new repo scope needs no edit
# here. The two lines below name the scopes in play, and the bullets refer to their kind.
{
printf '\n# Memory capture\n\nCross-cutting scopes: %s\n' "$ALWAYS"
repo=$(repo_here)
[ -n "$repo" ] && printf 'Repo scope: %s\n' "$repo"
cat <<'EOF'

Did this turn teach you a durable fact? A fact is durable when it stays true and useful in a month,
in another session, for someone who was not here.

**Writing nothing is the common and correct outcome.** Most turns teach none. An empty check costs
nothing, and a worthless note is permanent and makes every later search worse.

What qualifies differs by scope. Route a fact by its subject, so a fact about a scope not named
above still goes to that scope.

- A cross-cutting scope takes only what Matt told you or corrected you on in the message above, and
  only where it generalises past this task.
- A repo scope also takes what you worked out yourself: durable project state, a decision and its
  reason, an open thread, or a fact about the codebase and its tooling.

Skip what the transcript, the git history, the code, the docs or a skill already carries. A memory
points at the owning skill rather than restating it. Skip session summaries. Notes are topical
atoms, and a note spanning several topics matches no query well. When the session-start index
already names the note, `edit_note` it rather than adding a second one.

Write at most two notes. Use `write_note` or `edit_note` only, because `Edit` and `Write` leave the
search index stale. Pass `directory="/"`, or the note lands where the session-start index cannot see
it. Say in one line what you wrote, then get on with the reply.
EOF
}
