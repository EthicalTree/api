class S3
  def self.url(bucket=$s3_bucket, key="", expires=120)
    $fog.get_object_url(bucket, key, expires)
  end
end
