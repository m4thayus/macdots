# frozen_string_literal: true

require 'json'
require 'shellwords'

mixin 'suites' do
  def javascript_command(ci: false)
    return nil unless File.exist? 'package.json'
    return nil unless JSON.parse(File.read('package.json')).dig('scripts', 'test')

    runner = File.exist?('yarn.lock') ? 'yarn test' : 'npm test'

    ci ? "CI=true #{runner}" : runner
  end

  def ruby_command
    lock = File.exist?('Gemfile.lock') ? File.read('Gemfile.lock') : ''
    options = '--format failures --out /dev/stderr'
    return "rspec #{options}" unless lock.include? 'parallel_tests'

    "rails 'parallel:spec[,,#{options}]'"
  end
end

tool 'routes' do
  desc 'Add the route map to the bottom of config/routes.rb'

  include :bundler

  def run
    prefix = "# rubocop:disable Style/BlockComments\n=begin\n"
    suffix = "=end\n# rubocop:enable Style/BlockComments\n"

    rmap = `rails routes`
    routes = File.read('config/routes.rb')

    routes << "\n" unless routes.end_with? "\n"

    if routes.end_with? "\n#{suffix}"
      index = routes.rindex("\n#{prefix}")
      raise 'Cannot parse file' if index.nil?

      routes = routes[..index]
    end

    routes << prefix
    routes << rmap
    routes << suffix

    File.write('config/routes.rb', routes)
  end
end

tool 'test' do
  desc 'Run every available test suite, in parallel'

  include :bundler
  include :exec
  include 'suites'

  def run
    commands = [javascript_command(ci: true), ruby_command].compact

    puts "\e[1m$ #{commands.join(' & ')}\e[0m\n\n"

    jobs = commands.map { |cmd| exec(cmd, out: :null, err: :inherit, background: true) }
    pulse = Thread.new { heartbeat commands.zip(jobs) } if $stdout.tty?

    codes = jobs.map { |job| job.result.exit_code }

    pulse&.kill
    print "\e[2K\r" if $stdout.tty?

    exit codes.max
  end

  def heartbeat(pairs)
    started = Time.now
    stopped = {}

    loop do
      elapsed = pairs.map do |cmd, job|
        stopped[cmd] ||= Time.now if job.result timeout: 0
        "#{label cmd} #{((stopped[cmd] || Time.now) - started).round}s"
      end

      print "\e[2m\e[2K#{elapsed.join('  ')}\e[0m\r"
      sleep 1
    end
  end

  def label(command)
    Shellwords.split(command)
              .reject { |word| word.include? '=' }
              .take_while { |word| !word.start_with? '-' }
              .map { |word| word.split('[').first }
              .join(' ')
  end

  tool 'javascript' do
    desc 'Run the javascript test suite'

    include :exec
    include 'suites'

    def run
      cmd = javascript_command
      return logger.warn 'No javascript test script' if cmd.nil?

      exit exec(cmd).exit_code
    end
  end

  tool 'ruby' do
    desc 'Run the ruby test suite'

    include :bundler
    include :exec
    include 'suites'

    def run
      exit exec(ruby_command).exit_code
    end
  end

  tool 'js', delegate_relative: 'javascript'
  tool 'rb', delegate_relative: 'ruby'
end
