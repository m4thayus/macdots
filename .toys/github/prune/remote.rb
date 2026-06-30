# frozen_string_literal: true

desc 'Delete remote branches you exclusively own whose PR is merged or closed'
long_desc \
  'Lists branches on origin whose PR (merged OR closed-without-merge) is yours:',
  'every commit authored by you, and — if the PR has assignees — you the sole',
  'one. PRs with no assignee (e.g. GitHub Revert-button branches) qualify on',
  'sole authorship alone. Any collaboration — a co-assignee or a commit by',
  'anyone else — means the branch is skipped, as do open PRs (work in flight).',
  '',
  'Deleting is safe: every candidate has a PR, so GitHub keeps the commits at',
  'refs/pull/<n>/head and offers "Restore branch" even after deletion (merged',
  'work also lives on in main). A branch with no PR is never touched.',
  '',
  'Dry run by default: prints what WOULD be deleted to stdout, one line each as',
  '"<last-commit-date>  <branch>  (<reason>)". Pass --apply to `git push origin',
  '--delete`, printing the same lines to stderr.'

flag :apply, desc: 'Actually delete the branches on origin (default is a dry run)'

include 'identity'

def run
  require 'json'

  `git fetch --prune --quiet`

  ownable.each do |branch, reason|
    date = `git log -1 --format=%cs origin/#{branch}`.strip
    line = "#{date}  #{branch}  (#{reason})"

    if apply
      `git push origin --delete #{branch}`
      warn "deleted: #{line}"
    else
      puts line
    end
  end
rescue Errno::EPIPE
  # Reader closed early (head, grep -q, quitting less) — the dry-run print is
  # done anyway; exit quietly instead of dumping a backtrace.
end

# branch => reason ("merged"/"closed") for sole-assignee PRs still present on
# origin and authored entirely by you.
def ownable
  remote = remote_branches
  my_prs.select { |branch, _reason| remote.include?(branch) && solely_authored?(branch) }
end

def remote_branches
  `git for-each-ref --format='%(refname:short)' refs/remotes/origin`
    .split("\n").map { |ref| ref.delete_prefix('origin/') }
end

# branch => "merged"/"closed" for PRs that are yours. Ownership: sole assignee
# if any are set, else sole authorship alone (enforced by solely_authored? in
# ownable) — so web-UI PRs with no assignee, like Revert-button branches, still
# qualify. Co-assigned PRs are excluded. Open PRs are skipped. Merged wins if a
# branch had multiple PRs.
#
# Found via --author @me: PRs you opened (reverts/squash-merges included). That
# set is small, so --limit never silently truncates old PRs the way an
# unfiltered --state all would (it returns only the most recent N).
def my_prs
  json = `gh pr list --author @me --state all --json headRefName,state,assignees --limit 1000 2>/dev/null`
  return {} if json.empty?

  JSON.parse(json).each_with_object({}) do |pr, branches|
    next if pr['state'] == 'OPEN'

    assignees = pr['assignees'].map { |assignee| assignee['login'] }
    next unless assignees.empty? || assignees == [me_handle]

    branch = pr['headRefName']
    branches[branch] = pr['state'].downcase unless branches[branch] == 'merged'
  end
end

# True only if the branch has commits and every one is authored by you.
def solely_authored?(branch)
  base = `git merge-base origin/#{default_branch} origin/#{branch}`.strip
  return false if base.empty?

  authors = `git log #{base}..origin/#{branch} --format=%ae`.split("\n")
  authors.any? && authors.all? { |author| my_emails.include?(author) }
end

# origin's default branch, e.g. "main" — falls back to main if HEAD isn't set.
def default_branch
  name = `git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null`.strip
  name.empty? ? 'main' : name.delete_prefix('origin/')
end
