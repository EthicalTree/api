config = Rails.application.secrets[:aws]

if config

  Aws.config.update({
    region: config['s3_region'],
    credentials: Aws::Credentials.new(config['access_key'], config['secret_key'])
  })

  $s3_bucket = config['bucket']

end
