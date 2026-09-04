# frozen_string_literal: true

desc 'Regression tests for the TextEncoding module'

def run
  require 'fixtures'

  @failures = []
  check_scan
  check_fallback
  check_transcode
  check_double_encoding

  puts @failures.empty? ? "ok — #{Fixtures.count} fixtures" : @failures.join("\n")
  exit 1 unless @failures.empty?
end

def check(label, got, want)
  @failures << "#{label}: got #{got.inspect}, want #{want.inspect}" unless got == want
end

# Splitting UTF-8 characters from bytes that cannot be UTF-8 is the decision
# every other one rests on.
def check_scan
  Fixtures::ALL.each do |name, f|
    utf8, lone = TextEncoding.scan(f[:bytes])
    check("#{name} utf8 count", utf8.values.sum, f[:utf8])
    check("#{name} lone bytes", lone, f[:lone])
  end
end

# The regression that started this: 0x9D is a Mac Roman fingerprint and also the
# trailing byte of U+201D, so a raw byte scan calls every curly quote Mac Roman.
def check_fallback
  Fixtures::ALL.each do |name, f|
    next unless f[:expect]

    _, lone = TextEncoding.scan(f[:bytes])
    got = TextEncoding.single_byte(f[:bytes], lone).first
    if f[:expect] == :not_mac
      @failures << "#{name} fallback: got Mac Roman, want anything else" if got == 'Mac Roman'
    else
      check("#{name} fallback", got, f[:expect])
    end
  end
end

def check_transcode
  Fixtures::DECODED.each do |name, want|
    text, = TextEncoding.transcode(Fixtures::ALL[name][:bytes], Fixtures::FALLBACK[name])
    check("#{name} convert", text, want)
  end

  # A single-encoding file must convert exactly as iconv would, or this is a
  # regression dressed up as a feature.
  %w[cp1252 macroman].each do |name|
    bytes = Fixtures::ALL[name][:bytes]
    text, = TextEncoding.transcode(bytes, Fixtures::FALLBACK[name])
    check("#{name} matches iconv", text, bytes.encode('UTF-8', Fixtures::FALLBACK[name]))
  end
end

def check_double_encoding
  Fixtures::MANGLED.each do |source, want|
    got = TextEncoding.double_encoded(Fixtures.mangle(source)).map(&:last)
    check("mangled #{source.inspect}", got, want)
  end

  Fixtures::CLEAN.each do |source|
    check("clean #{source.inspect}", TextEncoding.double_encoded(source), [])
  end
end
