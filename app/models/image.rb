class Image < ApplicationRecord
  default_scope { order(order: :asc) }

  def url
    "https://#{$s3_ethicaltree_bucket}.s3.amazonaws.com/#{self.key}"
  end

  def thumbnail_url
    "https://#{$s3_thumbnails_bucket}.s3.amazonaws.com/#{self.key}"
  end

  def serializable_hash options={}
    super({
      methods: [:url, :thumbnail_url]
    }.merge(options))
  end

  def image_details
    if !self.width || !self.height
      file = $fog_ethicaltree.files.get(self.key)
      metadata = file.metadata

      self.width = metadata["x-amz-meta-width"]
      self.height = metadata["x-amz-meta-height"]
      self.save
    end

    {
      url: self.url,
      thumbnail_url: self.thumbnail_url,
      width: self.width,
      height: self.height
    }
  end
end

