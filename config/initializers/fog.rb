config = Rails.application.secrets[:aws]

if config
  $fog = Fog::Storage.new(
    provider: 'AWS',
    aws_access_key_id: config[:access_key],
    aws_secret_access_key: config[:secret_key]
  )

  $fog_ethicaltree = $fog.directories.new key: $s3_ethicaltree_bucket
  $fog_thumbnails = $fog.directories.new key: $s3_thumbnails_bucket
  $fog_db_backups = $fog.directories.new key: $s3_db_backups_bucket
end
