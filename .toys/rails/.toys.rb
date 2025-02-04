# frozen_string_literal: true

tool 'routes' do
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

tool 'test' do
  desc 'Run the full test suite'
  def run
    cli.run('rails test javascript')
    cli.run('rails test ruby')
    # system 'yarn test'
    # exec 'rspec'
  end

  tool 'javascript' do
    desc 'Run the javascript test suite'
    def run
      system 'yarn test'
    end
  end

  tool 'ruby' do
    desc 'Run the ruby test suite'
    def run
      system 'rspec'
    end
  end
end
