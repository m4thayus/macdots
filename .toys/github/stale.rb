# frozen_string_literal: true

desc 'List open PRs oldest-first — a staleness report (default: yours)'
long_desc \
  'Open PRs sorted by creation date, oldest first, so the graveyard floats to',
  'the top. Sorted by createdAt, NOT updatedAt — bulk edits (base-branch bumps,',
  'label sweeps) reset updatedAt and mask a PR\'s true age. Read-only.',
  '',
  'Defaults to your PRs. --user accepts a GitHub handle or a known first name',
  '(matt, scott, james, amit, elizabeth).'

flag :user, '--user WHO', default: '@me',
     desc: 'GitHub handle or first name to report on (default: you)'

include 'identity'

def run
  require 'json'

  json = `gh pr list --author #{resolve_handle(user)} --state open --limit 200 --json number,title,createdAt,updatedAt`
  prs = json.empty? ? [] : JSON.parse(json)

  prs.sort_by { |pr| pr['createdAt'] }.each do |pr|
    created = pr['createdAt'][0, 10]
    updated = pr['updatedAt'][0, 10]
    puts "#{created}  (touched #{updated})  ##{pr['number']}  #{pr['title']}"
  end
rescue Errno::EPIPE
  # Reader closed early (head, grep -q, quitting less) — exit quietly.
end
