config = Rails.application.secrets[:aws]

if config
  $fog = Fog::Storage.new(
    provider: 'AWS',
    aws_access_key_id: config[:access_key],
    aws_secret_access_key: config[:secret_key]
  )
end
