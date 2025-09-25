# frozen_string_literal: true

tool 'websafe' do
  desc 'Transcode a video to a websafe mp4'

  required_arg :input,
               complete: :file_system
  flag :rotate, '-r [DEGREE]', '--rotate [DEGREE]',
       default: nil, complete_values: [90, 270], accept: Integer

  # `-map 0:v:0 -map 0:a:0` — Only include the first video and audio streams.
  # `format=yuv420p` — 8-bit color, broad browser support.
  # `colorspace=all=bt709:iall=bt2020` — Converts from BT.2020 (HDR, wide gamut) to BT.709 (standard web color space).
  # `transpose=1` — Rotates 90° counterclockwise
  # `-c:v libx264` — Encodes with H.264.
  # `-profile:v high -level:v 4.1` — Good for browser/streaming compatibility.
  # `-pix_fmt yuv420p` — Required for wide compatibility.
  # `-crf 23 -preset slow` — Good quality/efficiency tradeoff
  # `-c:a aac -b:a 192k` — Audio as AAC, 192kbps.
  # `-movflags +faststart` — Makes playback start sooner in web players.

  def run
    input = options[:input]
    directory = File.dirname(input)
    output = File.join(directory, "#{File.basename(input, File.extname(input))}.websafe.mp4")

    transpose = case rotate
                when 90
                  '1'
                when 270
                  '2'
                end
                &.dup
                &.prepend(',transpose=')

    exec <<~BASH
      ffmpeg -i #{input} \\
      -map 0:v:0 -map 0:a:0 \\
      -vf "format=yuv420p,colorspace=all=bt709:iall=bt2020#{transpose}" \\
      -c:v libx264 -profile:v high -level:v 4.1 -pix_fmt yuv420p -crf 23 -preset slow \\
      -c:a aac -b:a 192k \\
      -movflags +faststart \\
      #{output}
    BASH
  end
end
