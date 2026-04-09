# frozen_string_literal: true

tool 'bonsai' do
  desc 'Slow-growing bonsai screensaver that keeps your laptop awake'
  long_desc 'Runs cbonsai in live mode via caffeinate, growing the tree over a full work day.',
            'Pass --hours to adjust the target growth duration (default: 10).',
            'Uses TERM=xterm-256color so colors work inside tmux.'

  flag :hours, '--hours [N]', default: 10 do
    desc 'Target hours for the tree to finish growing (default: 10)'
    accept Float
  end

  flag :life, '--life [N]', default: 32 do
    desc 'cbonsai --life value; higher = more complex tree (default: 32)'
    accept Integer
  end

  # cbonsai at --life 32 grows in ~175 steps; tune STEPS if your tree
  # finishes too early or too late.
  BONSAI_STEPS = 175

  def run
    step_delay = (hours * 3600.0 / BONSAI_STEPS).round(2)
    puts "Growing bonsai over #{hours}h — #{step_delay}s between steps. Ctrl-C to stop."

    pid = spawn('caffeinate', '-di')

    begin
      system(
        { 'TERM' => 'xterm-256color' },
        'cbonsai', '--live',
        '--time', step_delay.to_s,
        '--life', life.to_s
      )
    ensure
      Process.kill('TERM', pid)
      Process.wait(pid)
    end
  end
end

tool 'colortest' do
  desc 'Run a terminal color test'
  def run
    system 'msgcat --color=test'
  end
end

tool 'production' do
  ssh_hosts = lambda do |ctx|
    `grep "^Host\\s" ~/.ssh/config | cut -c6- | grep -v '*'`
      .split
      .filter { |s| s.start_with?(ctx.fragment) }
      .map { |s| Toys::Completion::Candidate.new(s) }
  end

  tool 'snapshots' do
    desc 'Fetch production database backups'

    required_arg :remote_host, complete: ssh_hosts
    flag :app, '--app [NAME]', default: 'talaria', complete_values: %w[talaria thoth livelabs quicksilver]
    flag :out, '--out [FILE]', complete_values: :file_system

    def run
      local_filepath = out || "~/Projects/mercury/#{app}/sandbox/"
      remote_file = case app
                    when 'talaria'
                      'backups/talaria-production.sql'
                    when 'thoth'
                      'backups/thoth_production.sql'
                    when 'livelabs'
                      'backups/livelabs_production.sql'
                    when 'quicksilver'
                      '/var/www/quicksilver/shared/data/production.sqlite3'
                    end
      exec "scp #{options[:remote_host]}:#{remote_file} #{local_filepath}"
    end
  end

  tool 'logs' do
    desc 'Fetch production logs'

    required_arg :remote_host, complete: ssh_hosts
    optional_arg :log_file, default: 'production.log'
    flag :app, '--app [NAME]', default: 'talaria', complete_values: %w[talaria thoth]
    flag :out, '--out [FILE]', complete_values: :file_system

    def run
      output_file = out || "#{options[:remote_host]}_#{options[:log_file]}"
      exec "scp #{options[:remote_host]}:/var/www/#{app}/shared/log/#{options[:log_file]} #{output_file}"
    end
  end

  tool 'cat' do
    desc 'Concatinate log files together in order'

    required_arg :log_file1, complete: :file_system
    required_arg :log_file2, complete: :file_system
    remaining_args :remaining_log_files, complete: :file_system

    def run
      exec "cat #{[options[:log_file1], options[:log_file2]].concat(options[:remaining_log_files]).join(' ')} | grep '^.,' | sort -n"
    end
  end
end
