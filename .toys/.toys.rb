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

ENCODINGS = {
  'mac' => 'MACROMAN',
  'unicode' => 'UTF8',
  'windows' => 'CP1252'
}.freeze

tool 'text' do
  tool 'detect' do
    desc 'Detect text file encoding'

    required_arg :file, complete: :file_system

    require 'rchardet'

    def run
      puts CharDet.detect(File.read(options[:file])).inspect
    end
  end

  tool 'convert' do
    desc 'Convert text file from source encoding to utf-8'

    required_arg :file, complete: :file_system
    required_arg :encoding, complete: %w[mac unicode windows]
    optional_arg :question_name
    flag :ext, '--ext [EXTENSION]', default: 'csv'

    def run
      if options[:question_name]
        exec "iconv -f #{ENCODINGS[options[:encoding]]} -t UTF8 #{options[:file]} > ~/#{options[:question_name]}.#{ext}"
      else
        exec "iconv -f #{ENCODINGS[options[:encoding]]} -t UTF8 #{options[:file]}"
      end
    end
  end
end
