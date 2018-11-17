class Image < ApplicationRecord
  default_scope { order(order: :asc) }

  def self.get_key_for_type options
    type = options[:type]
    slug = options[:slug]
    name = options[:name]

    if type == 'listing'
      key = "listings/#{slug}/images/#{name}"
    elsif type == 'menu'
      menu_id = options[:menu_id]
      key = "listings/#{slug}/menu/#{menu_id}/#{name}"
    elsif type == 'collection'
      key = "collections/#{slug}/images/#{name}"
    end

    key
  end

  def self.create_by_url url, type_info
    base_url = "https://#{$s3_ethicaltree_bucket}.s3.amazonaws.com/"

    # Don't recreate images that have already been uploaded
    if url.start_with? base_url
      if image = Image.find_by(key: url.gsub(base_url, ''))
        return image
      end
    end

    ext = File.extname(url.split('?')[0] || '')
    ext = ext.present? ? ext : 'jpg'
    uuid = "#{Digest::SHA256.hexdigest(url)}.#{ext}"
    name = "#{uuid.gsub('/', '_')}"

    key = self.get_key_for_type type_info.merge(name: name)
    res = HTTParty.get(url)

    if !image = Image.find_by(key: key)
      image = Image.new(key: key)

      $fog_ethicaltree.files.create({
        key: key,
        body: res.body,
        public: true
      })
    end

    image
  end

  def url
    "https://#{$s3_ethicaltree_bucket}.s3.amazonaws.com/#{self.key}"
  end

  def thumbnail_url
    "https://#{$s3_thumbnails_bucket}.s3.amazonaws.com/#{self.key}"
  end

  def serializable_hash options = {}
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
