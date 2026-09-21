# frozen_string_literal: true

desc 'Run the ruby test suite'

include :exec

def run
  cmd = Suites.ruby_command
  return logger.warn Suites::MISSING if cmd.nil?

  exit exec(cmd).exit_code
end
