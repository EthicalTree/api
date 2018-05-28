class Image < ApplicationRecord
  default_scope { order(order: :asc) }

  def url expiry=15.minutes.from_now.to_time.to_i
    $fog_images.files.new(key: self.key).url(expiry)
  end

  def thumbnail_url expiry=15.minutes.from_now.to_time.to_i
    $fog_thumbnails.files.new(key: self.key).url(expiry)
  end

  def serializable_hash options={}
    super({
      methods: [:url, :thumbnail_url]
    }.merge(options))
  end

  def image_details
    if !self.width || !self.height
      file = $fog_images.files.get(self.key)
      metadata = file.metadata

      self.width = metadata["x-amz-meta-width"]
      self.height = metadata["x-amz-meta-height"]
      self.save
    end

    {
      url: "https://#{$s3_images_bucket}.s3.amazonaws.com/#{self.key}",
      width: self.width,
      height: self.height
    }
  end
end

