# frozen_string_literal: true

desc 'Show notable PRs'
def run
  require 'date'
  require 'uri'
  require 'cgi'

  today = Date.today
  last_monday = today - today.cwday - 6

  options = [
    'org:mercuryanalytics',
    'is:pr',
    '-is:draft',
    '-label:dependencies',
    'label:notable',
    "closed:>=#{last_monday}"
  ]

  u = URI('https://github.com/search')
  u.query = { type: 'pullrequests', q: options.join(' ') }
            .transform_values! { |v| CGI.escape(v) }
            .map { |k, v| "#{k}=#{v}" }
            .join('&')
  puts u
end
