# Shared scope routing for the memory hooks. Sourced, not run.
#
# Both hooks have to agree on which scope a working directory is in. If they disagree, the index
# lists one scope and recall searches another, and nothing reports the mismatch.

MEM="$HOME/Vault/memory"
ALWAYS="personal mercury"

# Scope directory names under memory/repos are the Basic Memory scope names, so a new repo scope
# needs no edit here.
scope_exists() {
  [ -n "$(find "$MEM/repos" -mindepth 1 -maxdepth 2 -type d -name "$1" -print -quit 2>/dev/null)" ]
}

# The repo scope comes from cwd, which is the one thing Basic Memory cannot work out itself.
# Walking up from the deepest directory means the most specific ancestor wins.
repo_scope() {
  local d=$1 n
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    n=${d##*/}
    if scope_exists "$n"; then echo "$n"; return; fi
    d=${d%/*}
  done
  # $HOME is the macdots work tree, so $HOME itself or a dot-directory under it is dotfiles work.
  case "$1" in "$HOME"|"$HOME"/.*) echo macdots ;; esac
}

scope_dir() {
  case "$1" in
    personal|mercury) echo "$MEM/$1" ;;
    *) find "$MEM/repos" -mindepth 1 -maxdepth 2 -type d -name "$1" -print -quit 2>/dev/null ;;
  esac
}

# The scopes in play: the cross-cutting pair, plus the repo scope when cwd names one and it is not
# already in the pair.
scopes_here() {
  local repo; repo=$(repo_scope "$PWD")
  case " $ALWAYS " in *" $repo "*) repo="" ;; esac
  echo "$ALWAYS $repo"
}
