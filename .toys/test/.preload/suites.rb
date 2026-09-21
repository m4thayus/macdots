# frozen_string_literal: true

require 'json'

# Which test suites a directory holds, and the command that runs each one.
#
# Everything here reads the directory and returns a command string or nil. The
# tools decide whether to run one suite or all of them in parallel.
module Suites
  MISSING = 'No test suite found'

  def self.javascript_command(ci: false)
    return nil unless File.exist? 'package.json'
    return nil unless JSON.parse(File.read('package.json')).dig('scripts', 'test')

    runner = File.exist?('yarn.lock') ? 'yarn test' : 'npm test'

    ci ? "CI=true #{runner}" : runner
  end

  # NOTE: bundle exec is spelled out because the :bundler mixin raises
  # GemfileNotFoundError before run, locking the tools out of frontend-only
  # directories.
  def self.ruby_command
    return nil unless File.exist? 'Gemfile.lock'

    lock = File.read('Gemfile.lock')
    return nil unless lock.match?(/^\s+rspec/)

    options = '--format failures --out /dev/stderr'
    return "bundle exec rspec #{options}" unless lock.include? 'parallel_tests'

    "bundle exec rails 'parallel:spec[,,#{options}]'"
  end
end
