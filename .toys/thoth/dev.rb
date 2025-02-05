# frozen_string_literal: true

desc 'Start a thoth dev server'

include :bundler

def run
  `eslint_d restart`
  `rails vite:clobber`
  `rails restart`
  puts 'Starting server'
  exec 'vite dev'
end
