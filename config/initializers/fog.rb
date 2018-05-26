config = Rails.application.secrets[:aws]

if config
  $fog = Fog::Storage.new(
    provider: 'AWS',
    aws_access_key_id: config[:access_key],
    aws_secret_access_key: config[:secret_key]
  )

  $fog_images = $fog.directories.new key: $s3_images_bucket
  $fog_thumbnails = $fog.directories.new key: $s3_thumbnails_bucket
end
