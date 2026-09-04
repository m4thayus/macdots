# frozen_string_literal: true

desc 'Detect text file encoding'

required_arg :file, complete: :file_system

def run
  # Whole file, not a sample. A stray byte on the last line is exactly the case
  # worth catching, and it is the case a leading sample misses.
  puts TextEncoding.analyze(File.binread(file)).lines
end
