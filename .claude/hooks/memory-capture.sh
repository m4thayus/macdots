#!/bin/bash
# Stop hook: automatic capture. Asks the model, once a session has run long enough to have settled
# something, whether it produced a durable fact — and to write it if so.
#
# Stop is the only event that can do this. SessionEnd and PreCompact both discard their output, so
# neither can ask the model for anything; SessionEnd fires when the model is already gone. Exit 2 on
# Stop sends this script's stderr to the model, which is the whole mechanism.
#
# The Stop entry in settings.json sets `asyncRewake`, so exit 2 wakes the model in a fresh turn
# instead of blocking the current one. That is what keeps the prompt out of the transcript: the user
# sees the one-line `rewakeSummary` and the model still receives every line below. Drop those keys
# and the prompt renders in full, labelled a Stop hook error. `rewakeMessage` and `rewakeSummary`
# are marked @internal in 2.1.231, so recheck them after a Claude Code upgrade.
#
# The trigger is not discretionary. The write is, and that split is deliberate: model discretion
# measured zero when it had to decide to look, and a discretionary trigger is what this replaces.
# Deciding yes or no against an explicit question is a different act from remembering to ask it.

set -u
. "$HOME/.claude/hooks/memory-scope.sh"

STATE="$HOME/.claude/.memory-capture"
# The log sits beside the state directory rather than inside it, because the pruning find below
# would delete it during any week the hook did not fire — destroying the evidence that it did not.
LOG="$HOME/.claude/.memory-capture.log"

# Stop fires once per assistant turn, so counting fires counts turns without touching the
# transcript. Transcript bytes were the obvious proxy and a bad one — tool results dominate, so a
# single large grep outweighs a whole conversation.
#
# 6 is the median session length across 176 transcripts, and the quartile below it is one-shot
# questions that settle nothing. Repeating every 12 keeps a long session from capturing turn 6 and
# then nothing across the next forty. The counter only rises, so a fire can never re-match itself.
FIRST=6
EVERY=12

# Sessions and fires come from this hook's own log, organic writes from the transcripts. No single
# number means anything: sessions without fires says no session ran long enough, fires without
# writes says the bar rejects everything, and no sessions at all says the hook never ran. All three
# look like a tidy store from the outside.
if [ "${1:-}" = --stats ]; then
  python3 - "$LOG" <<'READOUT'
import collections, glob, json, os, sys

sessions, fires = collections.Counter(), collections.Counter()
try:
    with open(sys.argv[1]) as fh:
        for line in fh:
            day, _, kind = line.partition(" ")
            (fires if kind.startswith("fire") else sessions)[day[:10]] += 1
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

print(f"{'date':12}{'sessions':>10}{'fires':>7}{'writes':>8}")
for day in sorted(set(sessions) | set(fires) | set(writes)):
    print(f"{day:12}{sessions[day]:>10}{fires[day]:>7}{writes[day]:>8}")
print(f"{'total':12}{sum(sessions.values()):>10}{sum(fires.values()):>7}{sum(writes.values()):>8}")
READOUT
  exit 0
fi

IN=$(cat)
session=$(printf '%s' "$IN" | jq -r '.session_id // "nosession"')
HOOK_CWD=$(printf '%s' "$IN" | jq -r '.cwd // ""')
[ -d "$MEM" ] || exit 0

mkdir -p "$STATE"
find "$STATE" -type f -mtime +7 -delete 2>/dev/null
f="$STATE/$session"
n=$(( $(cat "$f" 2>/dev/null || echo 0) + 1 ))
echo "$n" >"$f"
[ "$n" -eq 1 ] &&
  printf '%s session id=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$session" >>"$LOG"

[ "$n" -ge "$FIRST" ] || exit 0
[ $(( (n - FIRST) % EVERY )) -eq 0 ] || exit 0

printf '%s fire session=%s turn=%s scopes="%s"\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$session" "$n" "$(scopes_here)" >>"$LOG"

{
printf '\n# Automatic memory capture\n\nScopes in play here: %s\n' "$(scopes_here)"
cat <<'EOF'

This session has run long enough to have settled something. Decide whether it did, write at most
two notes, then stop.

**Writing nothing is the common and correct outcome.** Most sessions produce no durable fact. An
empty capture costs one line. A worthless note is permanent and makes every later search worse.

## The bar

Write a fact only if it stays true and useful in a month, in another session, for someone who was
not here. That means one of:

- A preference or a correction Matt gave that generalises past this task.
- A convention, a handle, an ID, or a fact about a person or a tool.
- Durable project state — an open thread, or a decision and the reason behind it.

Do not write:

- What this session did. The transcript and the git history hold it already.
- Anything the code, the docs or a skill already carries. Rules live in skills, and a memory points
  at the owning skill rather than restating it.
- A session summary. One note per thread is the wrong shape here: notes are topical atoms, and a
  note spanning several topics averages into an embedding that matches no query well.
- Anything the session-start index already names, unless this session changed it. Then `edit_note`
  that note instead of writing a second one.

## Scope

Route by subject, not by working directory.

- Matt's own preferences and habits → `personal`
- Team conventions, handles, IDs, external repos → `mercury`
- A codebase's state and its repo-specific feedback → that repo's scope
- Dotfiles, shell, editor, terminal, agent config → `macdots`

A fact belonging to a scope not named above still goes to that scope.

## Mechanics

Use `write_note` and `edit_note` only. `Edit` and `Write` leave the search index stale.
`~/Vault/README.md` holds the note format. Say in one line what you wrote, then stop.
EOF
} >&2

exit 2
