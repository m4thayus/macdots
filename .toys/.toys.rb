# frozen_string_literal: true

tool 'logs' do
  tool 'production' do
    desc 'Fetch production logs'

    required_arg :app, complete: %w[talaria thoth]
    optional_arg :log_file, default: 'production.log'

    # def run
    #   remote_host = {}
    #   case options[:app]
    #   when 'talaria'
    #   when 'thoth'
    #     # scp remotehost:/path/to/remote/file /dev/stdout
    #   end
    # end
  end

  tool 'concat' do
    desc 'Concatinate log files together in order'

    optional_arg :log_file, complete: :file_system, default: 'aws1.log'
    remaining_args :remaining_log_files, complete: :file_system, default: ['aws2.log']

    def run
      puts "cat #{[options[:log_file]].concat(options[:remaining_log_files]).join(' ')} | grep ''^.,'' | sort -n"
    end
  end
end
