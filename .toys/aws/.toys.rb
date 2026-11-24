# frozen_string_literal: true

tool 'authorize' do
  desc 'Log in via AWS SSO (opens a browser)'

  flag :profile, '--profile PROFILE', default: ENV['AWS_PROFILE']

  def run
    # aws sso login blocks until the browser callback completes, so a plain
    # shell-out is all we need — no callback plumbing on our side.
    cmd = ['aws', 'sso', 'login']
    cmd += ['--profile', profile] if profile
    exit(1) unless system(*cmd)
  end

  tool 'legacy' do
    desc 'Exchange an MFA token code for 24h session credentials (pre-SSO)'

    required_arg :token_code
    flag :user, '--user USER', default: ENV['AWS_USER']

    def run
      require 'aws-sdk-core'

      creds = Aws::STS::Client.new(
        credentials: Aws::SharedCredentials.new(profile_name: 'mfa'),
        region: 'us-east-1'
      ).get_session_token(
        duration_seconds: 24 * 60 * 60,
        serial_number: "arn:aws:iam::681124311158:mfa/#{user}",
        token_code: options[:token_code]
      ).credentials

      # Be sure to install `awscli` with homebrew
      `aws configure set aws_access_key_id "#{creds.access_key_id}"`
      `aws configure set aws_secret_access_key "#{creds.secret_access_key}"`
      `aws configure set aws_session_token "#{creds.session_token}"`
    end
  end
end

tool 'node' do
  desc 'Find the public hostname of an EC2 instance by name pattern'

  required_arg :pattern

  def run
    require 'json'

    query = options[:pattern]
    pattern = Regexp.new(query)
    candidates = JSON.parse(`aws ec2 describe-instances`)['Reservations']
                     .flat_map { |r| r['Instances'] }
                     .reject { |i| i.dig('State', 'Name') == 'terminated' }
                     .select { |i| name(i) }

    matches = candidates.select { |i| name(i) == query }
    matches = candidates.select { |i| name(i) =~ pattern } if matches.empty?

    running = matches.select { |i| i.dig('State', 'Name') == 'running' }
    matches = running unless running.empty?

    case matches.size
    when 0 then abort 'Instance not found'
    when 1 then puts "Hostname #{hostname(matches.first)}"
    else abort "Ambiguous, #{matches.size} matches: #{matches.map { |i| name(i) }.sort.join(', ')}"
    end
  end

  def hostname(instance)
    host = instance['PublicDnsName'].to_s
    abort "#{name(instance)} is #{instance.dig('State', 'Name')} and has no public hostname" if host.empty?
    host
  end

  def name(instance)
    instance.fetch('Tags', []).find { |t| t['Key'] == 'Name' }&.fetch('Value', nil)
  end
end
