# frozen_string_literal: true

tool 'purge-local' do
  desc 'Delete all local branches except master or main'
  def run
    `git for-each-ref --format '%(refname:short)' refs/heads | grep -v "master\|main" | xargs git branch -D`
  end
end
