class S3

  def self.save model, key, file
    resource = Aws::S3::Resource.new
    resource.bucket($s3_bucket).object(key).put(body: file)

    model.key = key
    model.save
  end

end
