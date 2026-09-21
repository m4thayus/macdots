# frozen_string_literal: true

tool 'routes' do
  desc 'Add the route map to the bottom of config/routes.rb'

  include :bundler

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
