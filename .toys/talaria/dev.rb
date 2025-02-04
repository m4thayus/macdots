# frozen_string_literal: true

desc 'Start a talaria dev server'
def run
  `eslint_d restart`
  `rails webpacker:clobber`
  `rails restart`
  puts 'Starting server'
  exec 'webpacker-dev-server'
end
