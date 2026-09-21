# frozen_string_literal: true

require 'shellwords'

desc 'Run every available test suite, in parallel'

include :exec

def run
  commands = [Suites.javascript_command(ci: true), Suites.ruby_command].compact
  return logger.warn Suites::MISSING if commands.empty?

  puts "\e[1m$ #{commands.join(' & ')}\e[0m\n\n"

  started = Time.now
  stopped = {}
  codes = {}

  waits = commands.map do |cmd|
    job = exec(cmd, out: :null, err: :inherit, background: true)
    Thread.new do
      result = job.result
      stopped[cmd] = Time.now
      codes[cmd] = result.exit_code
    end
  end

  pulse = Thread.new { heartbeat commands, started, stopped }
  waits.each(&:join)
  pulse.kill

  print "\e[2K\r" if $stdout.tty?
  puts "\e[2m#{timings commands, started, stopped}\e[0m"

  exit codes.values.max
end

def heartbeat(commands, started, stopped)
  loop do
    line = timings commands, started, stopped
    print "\e[2m\e[2K#{line}\e[0m\r" if $stdout.tty?
    sleep 1
  end
end

def timings(commands, started, stopped)
  elapsed = commands.map do |cmd|
    seconds = ((stopped[cmd] || Time.now) - started).round
    "#{label cmd} #{duration seconds}"
  end

  elapsed.join('  ')
end

def duration(seconds)
  return "#{seconds}s" if seconds < 60

  format '%<minutes>d:%<seconds>02d', minutes: seconds / 60, seconds: seconds % 60
end

def label(command)
  Shellwords.split(command)
            .reject { |word| word.include?('=') || %w[bundle exec].include?(word) }
            .take_while { |word| !word.start_with? '-' }
            .map { |word| word.split('[').first }
            .join(' ')
end

tool 'js', delegate_relative: 'javascript'
tool 'rb', delegate_relative: 'ruby'
