class Meta
  def self.get_meta_tags protocol, webhost, path
    @url = "#{protocol}://#{webhost}/#{path}"

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

    generate_meta(meta, path)
  end

  private

  def self.match_seo_path path
    base_path = path.gsub(/\?.*/, '').downcase

    if base_path.first != '/'
      base_path = "/#{base_path}"
    end

    seo_path = (
      SeoPath.where('lower(path) = ?', base_path).first ||
      SeoPath.where('lower(path) = ?', base_path.chomp('/')).first
    )

    if seo_path.present?
      seo_path
    else
      nil
    end
  end

  def self.generate_meta item, path
    if path.present? && seo_match = match_seo_path(path)
      seo_meta = "
        <title>#{seo_match.title}</title>
        <meta name=\"description\" content=\"#{seo_match.description}\">
      "
    else
      seo_meta = "
        <meta name=\"description\" content=\"#{item[:description]}\">
      "
    end

    item.each { |k, v| item[k] = CGI::escapeHTML(v || '') }

    "
      #{seo_meta}
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
