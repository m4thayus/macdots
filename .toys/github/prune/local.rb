# frozen_string_literal: true

desc 'Prune local branches merged on origin, or that you never authored'
long_desc \
  'For each local branch (skipping the current one and origin\'s default),',
  'prune it if: it is merged into origin\'s default branch (ancestor check,',
  'then merged-PR state via gh to catch squash merges), its PR was closed',
  'without merging, or you have no commits on it — e.g. a branch you checked',
  'out to poke around.',
  '',
  'Dry run by default: prints what WOULD be pruned to stdout, one line each as',
  '"<last-commit-date>  <branch>  (<reason>)". Pass --apply to delete, printing',
  'the same lines to stderr.'

flag :apply, desc: 'Actually delete the branches (default is a dry run)'

include 'identity'

def run
  `git fetch --prune --quiet`

  branches.each do |branch|
    reason = prune_reason(branch) or next
    date = `git log -1 --format=%cs #{branch}`.strip
    line = "#{date}  #{branch}  (#{reason})"

    if apply
      `git branch -D #{branch}`
      warn "pruned: #{line}"
    else
      puts line
    end
  end
rescue Errno::EPIPE
  # Reader closed early (head, grep -q, quitting less) — the dry-run print is
  # done anyway; exit quietly instead of dumping a backtrace.
end

def branches
  skip = [default_branch, `git branch --show-current`.strip]
  `git for-each-ref --format='%(refname:short)' refs/heads`.split("\n") - skip
end

# origin's default branch, e.g. "main" — falls back to main if HEAD isn't set.
def default_branch
  name = `git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null`.strip
  name.empty? ? 'main' : name.delete_prefix('origin/')
end

def prune_reason(branch)
  return 'merged-local' if merged_locally?(branch)

  case pr_state(branch)
  when 'MERGED' then 'merged-pr'   # squash merges the ancestor check can't see
  when 'CLOSED' then 'closed-pr'   # abandoned without merging
  else 'not-mine' unless mine?(branch)
  end
end

def merged_locally?(branch)
  system("git merge-base --is-ancestor #{branch} origin/#{default_branch}",
         out: File::NULL, err: File::NULL)
end

# PR state for this branch via a direct --head lookup. Bounded by the (small)
# number of local branches, so unlike a bulk `gh pr list --limit N` it can't
# silently truncate old PRs. Returns "MERGED"/"CLOSED"/"OPEN", or nil if no PR.
def pr_state(branch)
  state = `gh pr list --head #{branch} --state all --limit 1 --json state --jq '.[0].state' 2>/dev/null`.strip
  state.empty? ? nil : state
end

def mine?(branch)
  authors = `git log origin/#{default_branch}..#{branch} --format=%ae`.split("\n")
  authors.any? { |author| my_emails.include?(author) }
end
