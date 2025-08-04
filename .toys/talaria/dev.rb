# frozen_string_literal: true

desc 'Start a talaria dev server'

include :bundler

def run
  `eslint_d restart`
  `rails shakapacker:clobber`
  `rails restart`
  puts 'Starting server'
  exec 'shakapacker-dev-server'
end
