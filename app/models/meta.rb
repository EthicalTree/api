class Meta

  def self.get_meta_tags url
    @url = url

    begin
      begin
        uri = URI.parse(@url)
      rescue
        uri = URI.parse(URI.escape(@url))
      end
    rescue
      return ""
    end

    meta = {
      name: 'EthicalTree',
      description: 'Best of Ottawa restaurants, bakeries, cafés and stores that are Organic, Woman-owned, Fair Trade, Vegan or Vegetarian',
      image: "#{Config.cdn}/images/et-social.png",
      image_width: '1200',
      image_height: '628'
    }
    cover_image = nil

    listing_slug = uri.path.scan(/\/listings\/(\w+)\/([\w-]+)\/?/)
    collection_slug = uri.path.scan(/\/collections\/(\w+)\/([\w-]+)\/?/)

    if listing_slug.present?
      if listing = Listing.find_by(slug: listing_slug[0][1])
        cover_image = listing.cover_image

        meta.merge!({
          name: listing.title,
          description: listing.bio
        })
      end
    elsif collection_slug.present?
      if collection = Collection.find_by(slug: collection_slug[0][1])
        cover_image = collection.cover_image

        meta.merge!({
          name: collection.name,
          description: collection.description,
        })
      end
    end

    if cover_image
      details = cover_image.image_details

      meta.merge!({
        image: details[:url],
        image_width: details[:width].to_s,
        image_height: details[:height].to_s
      })
    end

    generate_meta(meta)
  end

  private

  def self.generate_meta item
      item.each {|k, v| item[k] = CGI::escapeHTML(v || '')}

      "
        <meta name=\"description\" content=\"#{item[:description]}\">
        <meta property=\"og:url\" content=\"#{@url}\">
        <meta property=\"og:title\" content=\"#{item[:name]}\">
        <meta property=\"og:description\" content=\"#{item[:description]}\">
        <meta property=\"og:image\" content=\"#{item[:image]}\">
        <meta property=\"og:image:secure_url\" content=\"#{item[:image]}\">
        <meta property=\"og:image:width\" content=\"#{item[:image_width]}\">
        <meta property=\"og:image:height\" content=\"#{item[:image_height]}\">
        <meta property=\"og:site_name\" content=\"EthicalTree\">
        <meta name=\"twitter:card\" content=\"summary_large_image\">
        <meta name=\"fb:app_id\" content=\"#{Rails.application.secrets[:fb_app_id]}\">
      "
  end
end
