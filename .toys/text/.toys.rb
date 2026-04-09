# frozen_string_literal: true

require 'rchardet'

ENCODINGS = {
  'mac' => 'MACROMAN',
  'unicode' => 'UTF8',
  'windows' => 'CP1252'
}.freeze

tool 'detect' do
  desc 'Detect text file encoding'

  required_arg :file, complete: :file_system

  def run
    sample = File.binread(options[:file], 100_000)
    result = CharDet.detect(sample)
    encoding   = result['encoding']
    confidence = (result['confidence'].to_f * 100).round

    if result['confidence'].to_f < 0.99
      puts "Encoding: #{encoding} (#{confidence}% confidence) — low confidence, verify before converting"
    else
      puts "Encoding: #{encoding} (#{confidence}% confidence)"
    end
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
