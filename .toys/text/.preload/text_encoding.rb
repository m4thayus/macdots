# frozen_string_literal: true

require 'rchardet'

# Encoding analysis and repair for text files.
#
# Everything here takes raw bytes and returns plain data. The tools decide what
# to print and where to write, so the analysis stays testable on its own.
module TextEncoding
  # What the --from flag accepts, mapped to Ruby's encoding names.
  ENCODINGS = {
    'mac' => 'MACROMAN',
    'unicode' => 'UTF8',
    'windows' => 'CP1252'
  }.freeze

  # Bytes that are undefined in CP1252 but valid in Mac Roman — their presence
  # is a definitive Mac Roman fingerprint. rchardet can't see this because it
  # uses frequency stats, not a legality check, so it biases toward CP1252.
  #
  # Only sound once UTF-8 has been ruled out. 0x9D is also the trailing byte of
  # U+201D (E2 80 9D), so any file with a curly close-quote in it looks like Mac
  # Roman to a raw byte scan. Pass only the bytes that failed UTF-8 parsing.
  MACROMAN_ONLY_BYTES = [0x81, 0x8D, 0x8F, 0x90, 0x9D].freeze

  # Every character CP1252 can represent above ASCII, built from the encoding
  # table rather than hand-listed. Mojibake can only be spelled out of these,
  # because they are the whole alphabet a CP1252 misread has to draw on.
  CP1252_HIGH = (0x80..0xFF).filter_map do |b|
    b.chr.force_encoding('CP1252').encode('UTF-8')
  rescue Encoding::UndefinedConversionError
    nil
  end.join.freeze

  MOJIBAKE_RUN = /[#{Regexp.escape(CP1252_HIGH)}]{2,}/

  # One file's verdict. `lines` is the shared rendering, so detect and convert
  # cannot drift into describing the same file two different ways.
  Report = Struct.new(:utf8, :lone, :name, :confidence, :fallback, :mangled,
                      keyword_init: true) do
    def ascii? = utf8.empty? && lone.empty?
    def utf8? = lone.empty? && !utf8.empty?
    def mixed? = !utf8.empty? && !lone.empty?

    def lines
      [headline, *mixed_detail, *mangled_detail]
    end

    private

    def headline
      return 'Encoding: ASCII' if ascii?
      return "Encoding: UTF-8 (#{utf8.values.sum} multibyte characters)" if utf8?
      return "Encoding: MIXED — #{name} with UTF-8 already embedded in it" if mixed?

      label = "Encoding: #{name} (#{(confidence * 100).round}% confidence)"
      confidence < 0.99 ? "#{label} — low confidence, verify before converting" : label
    end

    def mixed_detail
      return [] unless mixed?

      ["  #{utf8.values.sum} chars parse as UTF-8 : #{TextEncoding.histogram(utf8)}",
       "  #{lone.values.sum} bytes do not         : #{TextEncoding.byte_histogram(lone)}",
       '  iconv would mangle one half or the other. convert handles it.']
    end

    def mangled_detail
      return [] if mangled.empty?

      repaired = mangled.map(&:last).join.each_char.tally
      ["Already mangled once: #{mangled.size} runs were written as UTF-8, then re-read as CP1252.",
       "  converting repairs them to : #{TextEncoding.histogram(repaired)}",
       '  if the file means them literally, that is the one case to fix by hand.']
    end
  end

  # The whole verdict for a file, in one pass.
  def self.analyze(data)
    utf8, lone = scan(data)
    name, confidence = lone.empty? ? [nil, 1.0] : single_byte(data, lone)
    fallback = if lone.empty? then 'UTF8'
               elsif name == 'Mac Roman' then 'MACROMAN'
               else 'CP1252'
               end
    text, = transcode(data, fallback)

    Report.new(utf8: utf8, lone: lone, name: name, confidence: confidence,
               fallback: fallback, mangled: double_encoded(text))
  end

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
    [clean.each_char.reject(&:ascii_only?).tally, lone]
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

  # Finds text that was already mangled once: written as UTF-8, read back as
  # CP1252, written out again, which is what turns `café` into `cafÃ©`.
  #
  # A run of CP1252-range characters that re-encodes into *fewer* characters of
  # valid UTF-8 can only have got that way by being encoded twice. Honest text
  # fails the test — `créé` re-encodes to E9 E9, which is not valid UTF-8.
  #
  # Converting the file silently repairs these. That is nearly always what you
  # want, so this reports rather than blocks.
  #
  # Returns [[as_written, as_repaired], ...].
  def self.double_encoded(text)
    text.scan(MOJIBAKE_RUN).filter_map do |run|
      repaired = run.encode('CP1252').dup.force_encoding('UTF-8')
      next unless repaired.valid_encoding? && !repaired.ascii_only?
      next unless repaired.length < run.length

      [run, repaired]
    end
  end

  def self.histogram(tally)
    tally.sort_by { |_, n| -n }.map { |v, n| "#{v} x#{n}" }.join('  ')
  end

  def self.byte_histogram(tally)
    histogram(tally.transform_keys { |b| format('0x%02X', b) })
  end
end
