# frozen_string_literal: true

tool 'route-map' do
  desc 'Add the route map to the bottom of config/routes.rb'

  def run
    prefix = "# rubocop:disable Style/BlockComments\n=begin\n"
    suffix = "=end\n# rubocop:enable Style/BlockComments\n"

    rmap = `rails routes`
    routes = File.read('config/routes.rb')

    routes << "\n" unless routes.end_with? "\n"

    if routes.end_with? "\n#{suffix}"
      index = routes.rindex("\n#{prefix}")
      raise 'Cannot parse file' if index.nil?

      routes = routes[..index]
    end

    routes << prefix
    routes << rmap
    routes << suffix

    File.write('config/routes.rb', routes)
  end
end

tool 'dev-server' do
  desc 'Start a dev server'

  def run
    `eslint_d restart`
    `rails webpacker:clobber`
    `rails restart`
    puts 'Starting server'
    exec 'webpacker-dev-server'
  end
end

tool 'notable' do
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
end
