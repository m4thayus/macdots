# frozen_string_literal: true

require 'base64'

# Extension <-> mime, the only formats the original scripts handled.
MIME = {
  'png' => 'image/png',
  'jpg' => 'image/jpeg',
  'jpeg' => 'image/jpeg',
  'gif' => 'image/gif'
}.freeze
EXT = { 'image/png' => 'png', 'image/jpeg' => 'jpg', 'image/gif' => 'gif' }.freeze

tool 'encode' do
  desc 'Encode an image as a base64 data: URL in a TS module (file.png -> file.ts)'

  optional_arg :file, complete: :file_system
  flag :type, '--type EXT', complete_values: MIME.keys,
       desc: 'Image type when piping via stdin (png/jpg/gif)'

  def run
    file = options[:file]
    key = options[:type] || (file && File.extname(file).delete('.'))
    mime = MIME[key&.downcase] or raise "Unknown image type: #{key.inspect}"

    bytes = file ? File.binread(file) : $stdin.binmode.read
    data = Base64.strict_encode64(bytes)
    line = %(export default "data:#{mime};base64,#{data}")

    # No file => piped in: emit the module to stdout instead of writing a .ts.
    return puts(line) unless file

    out = "#{file.chomp(File.extname(file))}.ts"
    File.write(out, "#{line}\n")
    puts out
  end
end

tool 'decode' do
  desc 'Decode a TS data: URL module back into its image file'

  optional_arg :file, complete: :file_system

  def run
    file = options[:file]
    source = file ? File.read(file) : $stdin.read
    match = source.match(%r{data:([^;]+);base64,([^"]+)}) or
      raise 'No data URL found'
    mime, data = match.captures
    bytes = Base64.decode64(data)

    # No file => piped in: decode straight to stdout (the original `| dataurl`).
    return $stdout.binmode.write(bytes) unless file

    ext = EXT[mime] or raise "Unknown mime type: #{mime}"
    out = "#{file.chomp('.ts')}.#{ext}"
    File.binwrite(out, bytes)
    puts out
  end
end
