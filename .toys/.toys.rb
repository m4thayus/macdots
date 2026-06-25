# frozen_string_literal: true

require 'tmpdir'

tool 'bonsai' do
  desc 'Slow-growing bonsai screensaver that keeps your laptop awake'
  long_desc 'Runs cbonsai in live mode via caffeinate, growing the tree over a full work day.',
            'Pass --hours to adjust the target growth duration (default: 10).',
            'Redraws on terminal resize (cbonsai itself ignores SIGWINCH) by restarting',
            'with --load at the current growth point, so a resize recenters the same tree.',
            'Uses TERM=xterm-256color so colors work inside tmux.'

  flag :hours, '--hours [N]', default: 10 do
    desc 'Target hours for the tree to finish growing (default: 10)'
    accept Float
  end

  flag :life, '--life [N]', default: 32 do
    desc 'cbonsai --life value; higher = more complex tree (default: 32)'
    accept Integer
  end

  flag :seed, '--seed [N]' do
    desc 'RNG seed; fixed so resizes redraw the same tree (default: random)'
    accept Integer
  end

  def run
    tree_seed = seed || rand(1..32_767)
    save = File.join(Dir.tmpdir, "cbonsai-#{Process.pid}.save")

    # Pre-grow once to /dev/null to learn this seed/life's real branch count.
    # cbonsai's save file is "seed branchCount"; each branch is one live step,
    # so the final count is both our step total and the unit for resize-resume.
    system('cbonsai', '-s', tree_seed.to_s, '-L', life.to_s, '-p', '-W', save,
           out: File::NULL, err: File::NULL)
    total = [File.read(save).split[1].to_i, 1].max
    step_delay = (hours * 3600.0 / total).round(3)
    puts "Growing bonsai over #{hours}h (seed #{tree_seed}, #{total} steps, #{step_delay}s each). Ctrl-C to stop."

    caffeine = spawn('caffeinate', '-di')
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    pid = nil
    resized = false
    # cbonsai can't redraw on resize, so wake the blocking wait below by killing
    # it; the loop then relaunches at the current growth point for the new size.
    trap('WINCH') do
      resized = true
      Process.kill('TERM', pid) if pid
    end

    begin
      loop do
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
        branches = (elapsed / step_delay).to_i.clamp(0, total)
        File.write(save, "#{tree_seed} #{branches}")

        args = ['cbonsai', '--live', '--time', step_delay.to_s, '--life', life.to_s,
                '--seed', tree_seed.to_s, '--save', save]
        # --load rebuilds instantly to `branches` at the current terminal size
        # (no per-step sleep) before resuming live growth.
        args += ['--load', save] if branches.positive?

        resized = false
        pid = spawn({ 'TERM' => 'xterm-256color' }, *args)
        Process.wait(pid) # blocks until resize-kill or the tree finishes growing
        break unless resized
      end
    ensure
      trap('WINCH', 'DEFAULT')
      Process.kill('TERM', caffeine)
      Process.wait(caffeine)
      File.delete(save) if File.exist?(save)
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
