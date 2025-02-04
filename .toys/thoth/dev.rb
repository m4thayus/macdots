# frozen_string_literal: true

desc 'Start a thoth dev server'
def run
  `eslint_d restart`
  `rails vite:clobber`
  `rails restart`
  puts 'Starting server'
  exec './node_modules/.bin/vite'
end
