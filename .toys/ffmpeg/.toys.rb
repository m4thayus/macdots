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

tool 'hls' do
  desc 'Transcode a video into an adaptive HLS ladder (720p/360p + source)'

  # -g/-keyint_min 60 assume ~30fps source; CBR x264 so segments align across
  # renditions for clean adaptive switching.
  required_arg :input, complete: :file_system
  required_arg :output_dir, complete: :file_system

  def run
    dir = options[:output_dir]
    # ffmpeg won't create the per-rendition subdirs the segment paths reference.
    3.times { |i| FileUtils.mkdir_p(File.join(dir, "stream_#{i}")) }

    exec <<~BASH
      ffmpeg -i #{input} \\
      -filter_complex \\
      "[0:v]split=3[v1][v2][v3]; \\
      [v1]copy[v1out]; [v2]scale=w=-1:h=720[v2out]; [v3]scale=w=-1:h=360[v3out]" \\
      -map [v1out] -c:v:0 libx264 -x264-params "nal-hrd=cbr:force-cfr=1" -b:v:0 5M -maxrate:v:0 5M -minrate:v:0 5M -bufsize:v:0 10M -preset slow -g 60 -sc_threshold 0 -keyint_min 60 \\
      -map [v2out] -c:v:1 libx264 -x264-params "nal-hrd=cbr:force-cfr=1" -b:v:1 3M -maxrate:v:1 3M -minrate:v:1 3M -bufsize:v:1 3M -preset slow -g 60 -sc_threshold 0 -keyint_min 60 \\
      -map [v3out] -c:v:2 libx264 -x264-params "nal-hrd=cbr:force-cfr=1" -b:v:2 1M -maxrate:v:2 1M -minrate:v:2 1M -bufsize:v:2 1M -preset slow -g 60 -sc_threshold 0 -keyint_min 60 \\
      -map a:0 -c:a:0 aac -b:a:0 96k -ac 2 \\
      -map a:0 -c:a:1 aac -b:a:1 96k -ac 2 \\
      -map a:0 -c:a:2 aac -b:a:2 48k -ac 2 \\
      -f hls \\
      -start_number 0 \\
      -hls_time 2 \\
      -hls_playlist_type vod \\
      -hls_segment_filename #{dir}/stream_%v/data%02d.ts \\
      -master_pl_name master.m3u8 \\
      -var_stream_map "v:0,a:0 v:1,a:1 v:2,a:2" #{dir}/stream_%v/playlist.m3u8
    BASH
  end
end
