# frozen_string_literal: true

tool 'import' do
  desc 'Convert *.jpg in the current dir to png and move to ~/Pictures/Backgrounds'

  def run
    dest = File.expand_path('~/Pictures/Backgrounds')
    FileUtils.mkdir_p(dest)

    Dir['*.jpg'].each do |jpg|
      png = "#{File.basename(jpg, '.jpg')}.png"
      exec(['gm', 'convert', '-verbose', jpg, png])
      # -n: never clobber an existing background
      exec(['mv', '-vn', png, dest])
    end
  end
end
