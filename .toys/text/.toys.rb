# frozen_string_literal: true

require 'rchardet'

ENCODINGS = {
  'mac' => 'MACROMAN',
  'unicode' => 'UTF8',
  'windows' => 'CP1252'
}.freeze

# Bytes that are undefined in CP1252 but valid in Mac Roman — their presence
# is a definitive Mac Roman fingerprint. rchardet can't see this because it
# uses frequency stats, not a legality check, so it biases toward CP1252.
MACROMAN_ONLY_BYTES = [0x81, 0x8D, 0x8F, 0x90, 0x9D].freeze

tool 'detect' do
  desc 'Detect text file encoding'

  required_arg :file, complete: :file_system

  def run
    sample = File.binread(options[:file], 100_000)
    result = CharDet.detect(sample)
    encoding   = result['encoding']
    confidence = result['confidence'].to_f

    # rchardet conflates CP1252 and Mac Roman. If it returns any Windows/ISO
    # single-byte variant, run a definitive check: any byte undefined in CP1252
    # can only have come from a Mac Roman file.
    if encoding =~ /windows|cp1252|iso-8859/i
      if sample.bytes.any? { |b| MACROMAN_ONLY_BYTES.include?(b) }
        encoding   = 'Mac Roman'
        confidence = 1.0
      end
    end

    pct   = (confidence * 100).round
    label = "Encoding: #{encoding} (#{pct}% confidence)"
    label += " — low confidence, verify before converting" if confidence < 0.99
    puts label
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
