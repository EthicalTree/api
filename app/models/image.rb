class Image < ApplicationRecord
  default_scope { order(order: :asc) }

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

