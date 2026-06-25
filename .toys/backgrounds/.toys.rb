# frozen_string_literal: true

tool 'import' do
  desc 'Convert *.jpg in the current dir to png and move to ~/Pictures/Backgrounds'

  def run
    dest = File.expand_path('~/Pictures/Backgrounds')
    FileUtils.mkdir_p(dest)

    Dir['*.jpg'].each do |jpg|
      system('gm', 'convert', '-verbose', jpg, "#{File.basename(jpg, '.jpg')}.png")
    end

    # Move every png — both freshly converted and any already in the dir.
    # -n: never clobber an existing background.
    Dir['*.png'].each { |png| system('mv', '-vn', png, dest) }
  end
end
