config = Rails.application.secrets[:aws]

if config

  Aws.config.update({
    region: config[:s3_region],
    credentials: Aws::Credentials.new(config[:access_key], config[:secret_key])
  })

  $s3_images_bucket = config[:images_bucket]
  $s3_thumbnails_bucket = config[:thumbnails_bucket]
  $s3_db_backups_bucket = config[:db_backups_bucket]
end
