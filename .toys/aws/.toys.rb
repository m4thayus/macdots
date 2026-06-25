# frozen_string_literal: true

tool 'authorize' do
  desc 'Exchange an MFA token code for 24h session credentials'

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

tool 'node' do
  desc 'Find the public hostname of an EC2 instance by name pattern'

  required_arg :pattern

  def run
    require 'json'

    pattern = Regexp.new(options[:pattern])
    instance = JSON.parse(`aws ec2 describe-instances`)['Reservations']
                   .flat_map { |r| r['Instances'] }
                   .reject { |i| i.dig('State', 'Name') == 'terminated' }
                   .find { |i| name(i) =~ pattern }

    if instance
      puts "Hostname #{instance['PublicDnsName']}"
    else
      warn 'Instance not found'
    end
  end

  def name(instance)
    instance.fetch('Tags', []).find { |t| t['Key'] == 'Name' }&.fetch('Value', nil)
  end
end
