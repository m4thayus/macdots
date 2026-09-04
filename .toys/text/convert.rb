# frozen_string_literal: true

desc 'Convert a text file to UTF-8'

long_desc 'Reports what the file is before converting it, so you see the same ' \
          'thing `toys text detect` would tell you. The source encoding is ' \
          'detected unless you name one with --from.',
          '',
          'Everything the tool says goes to stderr, so `convert FILE > out.csv` ' \
          'stays a clean pipe.'

required_arg :file, complete: :file_system

flag :from, '--from ENCODING',
     accept: TextEncoding::ENCODINGS.keys,
     complete_values: TextEncoding::ENCODINGS.keys,
     desc: 'Source encoding. Detected when omitted.'

flag :out, '--out NAME',
     desc: 'Write here instead of stdout. A bare name lands in /tmp as .csv.'

def run
  data = File.binread(file)
  report = TextEncoding.analyze(data)
  warn report.lines.join("\n")

  fallback = from ? TextEncoding::ENCODINGS[from] : report.fallback
  warn "Reading the rest as #{fallback}#{' (detected)' unless from}."

  text, recoded = TextEncoding.transcode(data, fallback)
  warn "Recoded #{recoded} bytes, kept #{data.bytesize - recoded} as-is."

  return print(text) unless out

  path = destination(out)
  File.write(path, text)
  warn "Wrote #{path}"
end

# A bare name goes to /tmp, which the machine clears on restart. These files
# exist to be checked and copied to a server, not to pile up in $HOME. Anything
# with a slash in it is taken as the path the caller meant.
def destination(name)
  name = "#{name}.csv" if File.extname(name).empty?
  name.include?('/') ? File.expand_path(name) : File.join('/tmp', name)
end
