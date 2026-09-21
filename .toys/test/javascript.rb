# frozen_string_literal: true

desc 'Run the javascript test suite'

include :exec

def run
  cmd = Suites.javascript_command
  return logger.warn Suites::MISSING if cmd.nil?

  exit exec(cmd).exit_code
end
