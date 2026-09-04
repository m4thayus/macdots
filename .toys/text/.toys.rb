# frozen_string_literal: true

require 'rchardet'

ENCODINGS = {
  'mac' => 'MACROMAN',
  'unicode' => 'UTF8',
  'windows' => 'CP1252'
}.freeze

module TextEncoding
  # Bytes that are undefined in CP1252 but valid in Mac Roman — their presence
  # is a definitive Mac Roman fingerprint. rchardet can't see this because it
  # uses frequency stats, not a legality check, so it biases toward CP1252.
  #
  # Only sound once UTF-8 has been ruled out. 0x9D is also the trailing byte of
  # U+201D (E2 80 9D), so any file with a curly close-quote in it looks like Mac
  # Roman to a raw byte scan. Pass only the bytes that failed UTF-8 parsing.
  MACROMAN_ONLY_BYTES = [0x81, 0x8D, 0x8F, 0x90, 0x9D].freeze

  # Separates the two populations that decide a file's encoding: characters that
  # parse as UTF-8, and high bytes that cannot. A file holding both is mixed, and
  # no single-encoding pass can convert it.
  #
  # Returns [utf8_char_tally, lone_byte_tally], both Hashes of value => count.
  def self.scan(data)
    lone = Hash.new(0)
    clean = data.b.force_encoding('UTF-8').scrub do |bad|
      bad.each_byte { |b| lone[b] += 1 }
      ''
    end
    utf8 = clean.each_char.reject(&:ascii_only?).tally
    [utf8, lone]
  end

  # Decodes to UTF-8, keeping any sequence that is already well-formed UTF-8 and
  # falling back to `fallback` for the bytes that aren't. Equivalent to iconv for
  # a single-encoding file, and the only thing that works on a mixed one.
  #
  # Returns [text, recoded_byte_count].
  def self.transcode(data, fallback)
    recoded = 0
    text = data.b.force_encoding('UTF-8').scrub do |bad|
      recoded += bad.bytesize
      bad.encode('UTF-8', fallback, invalid: :replace, undef: :replace)
    end
    [text, recoded]
  end

  # Names the single-byte encoding behind `lone`. rchardet only ever sees a
  # sample, so it stays a guess, reported with its confidence.
  def self.single_byte(data, lone)
    return ['Mac Roman', 1.0] if lone.keys.any? { |b| MACROMAN_ONLY_BYTES.include?(b) }

    result = CharDet.detect(data[0, 100_000])
    name = result['encoding'].to_s
    name = 'CP1252' if name =~ /windows|cp1252|iso-8859/i
    [name, result['confidence'].to_f]
  end

  def self.histogram(tally)
    tally.sort_by { |_, n| -n }.map { |v, n| "#{v} x#{n}" }.join('  ')
  end

  def self.byte_histogram(tally)
    histogram(tally.transform_keys { |b| format('0x%02X', b) })
  end
end

tool 'detect' do
  desc 'Detect text file encoding'

  required_arg :file, complete: :file_system

  def run
    # Whole file, not a sample. A single stray byte on the last line is exactly
    # the case worth catching, and it is the case a leading sample misses.
    data = File.binread(options[:file])
    utf8, lone = TextEncoding.scan(data)

    if lone.empty?
      puts utf8.empty? ? 'Encoding: ASCII' : "Encoding: UTF-8 (#{utf8.values.sum} multibyte characters)"
      return
    end

    name, confidence = TextEncoding.single_byte(data, lone)

    if utf8.empty?
      label = "Encoding: #{name} (#{(confidence * 100).round}% confidence)"
      label += ' — low confidence, verify before converting' if confidence < 0.99
      puts label
      return
    end

    puts "Encoding: MIXED — #{name} with UTF-8 already embedded in it"
    puts "  #{utf8.values.sum} chars parse as UTF-8 : #{TextEncoding.histogram(utf8)}"
    puts "  #{lone.values.sum} bytes do not         : #{TextEncoding.byte_histogram(lone)}"
    puts '  iconv would mangle one half or the other. `toys text convert` handles it.'
  end
end

tool 'convert' do
  desc 'Convert text file from source encoding to utf-8'

  required_arg :file, complete: :file_system
  required_arg :encoding, complete: %w[mac unicode windows]
  optional_arg :question_name
  flag :ext, '--ext [EXTENSION]', default: 'csv'

  def run
    data = File.binread(options[:file])
    text, recoded = TextEncoding.transcode(data, ENCODINGS[options[:encoding]])

    warn "Recoded #{recoded} bytes from #{ENCODINGS[options[:encoding]]}, kept #{data.bytesize - recoded} as-is." if recoded.positive?

    if options[:question_name]
      File.write(File.expand_path("~/#{options[:question_name]}.#{ext}"), text)
    else
      print text
    end
  end
end

tool 'test' do
  desc 'Regression tests for encoding detect and convert'

  def run
    require_relative 'fixtures'
    failures = []
    check = lambda do |name, got, want|
      failures << "#{name}: got #{got.inspect}, want #{want.inspect}" unless got == want
    end

    Fixtures::ALL.each do |name, f|
      utf8, lone = TextEncoding.scan(f[:bytes])
      check["#{name} utf8 count", utf8.values.sum, f[:utf8]]
      check["#{name} lone bytes", lone, f[:lone]]

      case f[:expect]
      when 'Mac Roman'
        check["#{name} fallback", TextEncoding.single_byte(f[:bytes], lone).first, 'Mac Roman']
      when :not_mac
        got = TextEncoding.single_byte(f[:bytes], lone).first
        failures << "#{name} fallback: got Mac Roman, want anything else" if got == 'Mac Roman'
      end

      next unless Fixtures::DECODED.key?(name)

      text, = TextEncoding.transcode(f[:bytes], Fixtures::FALLBACK[name])
      check["#{name} convert", text, Fixtures::DECODED[name]]
    end

    # A single-encoding file must convert exactly as iconv would, or this is a
    # regression dressed up as a feature.
    %w[cp1252 macroman].each do |name|
      bytes = Fixtures::ALL[name][:bytes]
      text, = TextEncoding.transcode(bytes, Fixtures::FALLBACK[name])
      check["#{name} matches iconv", text, bytes.encode('UTF-8', Fixtures::FALLBACK[name])]
    end

    puts failures.empty? ? "ok — #{Fixtures::ALL.size} fixtures" : failures.join("\n")
    exit 1 unless failures.empty?
  end
end
