#!/bin/bash
# SessionStart hook: prints an index of Basic Memory note titles for the scopes in play.
#
# Titles and permalinks only, never bodies. This is the store's shape — what exists and, by
# omission, what does not. Relevance is memory-recall.sh's job, on UserPromptSubmit.
#
# Reads the markdown rather than asking the basic-memory CLI, for two reasons: the CLI has no verb
# that lists a project's notes, and its one search verb costs 2.3s per project against a 5s hook
# timeout. The markdown is the source of truth here, so it also cannot be stale.

. "$HOME/.claude/hooks/memory-scope.sh"

# ponytail: a note with no `title:` line is omitted. See --check below.
list_scope() {
  local dir body count
  dir=$(scope_dir "$1")
  [ -d "$dir" ] || return
  body=$(grep -m1 -H '^title: ' "$dir"/*.md 2>/dev/null |
    sed -e 's|.*/||' -e 's|\.md:title: | — |' -e 's|^|- |' | sort)
  [ -n "$body" ] || return
  count=$(printf '%s\n' "$body" | wc -l | tr -d ' ')
  printf '\n**%s** — %s notes\n%s\n' "$1" "$count" "$body"
}

# Two invariants the index cannot survive without, checked against the vault rather than against
# this script. Both fail silently in production: a note with no `title:` is dropped from a list the
# header calls complete, and a permalink that diverges from its filename makes the index print an
# identifier that resolves nowhere. Notes get written constantly, so these keep earning.
if [ "$1" = --check ]; then
  fail=0
  check() { # description, expected, actual
    if [ "$2" = "$3" ]; then echo "ok    $1"; else echo "FAIL  $1: want '$2', got '$3'"; fail=1; fi
  }
  check "every note has a title" "" "$(find "$MEM" -name '*.md' -exec grep -Lm1 '^title: ' {} +)"
  check "permalink matches filename" "" \
    "$(find "$MEM" -name '*.md' | while read -r f; do
         p=$(sed -n 's/^permalink: *//p' "$f" | head -1)
         b=${f##*/}; [ -n "$p" ] && [ "$p" != "${b%.md}" ] && echo "$f"
       done)"
  exit $fail
fi

scopes=$(scopes_here)

cat <<'HEADER'
# Basic Memory index

Every note in the scopes below, by permalink and title. This is the store's shape, not its
contents — relevant notes arrive on their own when you ask something they answer.

**This index is the complete list.** A fact that is not named here is not in the store, so write it
rather than searching for it.

**Writes go through `write_note` or `edit_note`, never `Edit` or `Write`.** The file tools work on
these paths and leave the search index stale, which takes a `basic-memory reindex` you have to
remember. Reads are safe by any means.
HEADER

for s in $scopes; do list_scope "$s"; done

# Silence would be indistinguishable from a broken hook, and reading absence as "there is nothing
# here" is the failure this whole mechanism exists to fix.
set -- $scopes
[ $# -ge 3 ] ||
  printf '\nNo repo scope matches this working directory, so only the cross-cutting scopes load.\n'
