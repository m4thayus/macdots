# frozen_string_literal: true

tool 'colortest' do
  desc 'Run a terminal color test'
  def run
    system 'msgcat --color=test'
  end
end

tool 'logs' do
  tool 'production' do
    desc 'Fetch production logs'

    required_arg :remote_host
    optional_arg :log_file, default: 'production.log'
    flag :app, '--app [NAME]', default: 'talaria', complete_values: %w[talaria thoth]
    flag :out, '--out [FILE]', complete_values: :file_system

    def run
      output_file = out || "#{options[:remote_host]}_#{options[:log_file]}"
      exec "scp #{options[:remote_host]}:/var/www/#{app}/shared/log/#{options[:log_file]} #{output_file}"
    end
  end

  tool 'concat' do
    desc 'Concatinate log files together in order'

    required_arg :log_file1, complete: :file_system
    required_arg :log_file2, complete: :file_system
    remaining_args :remaining_log_files, complete: :file_system

    def run
      exec "cat #{[options[:log_file1], options[:log_file2]].concat(options[:remaining_log_files]).join(' ')} | grep ''^.,'' | sort -n"
    end
  end
end
