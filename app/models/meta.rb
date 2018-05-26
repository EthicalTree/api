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
      description: 'Best of Ottawa restaurants, bakeries, cafés and stores that are Organic, Woman-owned, Fair Trade, Vegan and/or Vegetarian',
      image: "#{Config.cdn}/images/et-social.png",
      image_width: '1200',
      image_height: '628'
    }

    listing_slug = uri.path.scan(/\/listings\/\w+\/([\w-]+)\/?/)
    curated_list_slug = uri.path.scan(/\/collections\/\w+\/([\w-]+)\/?/)

    if listing_slug.present?
      if listing = Listing.find_by(slug: listing_slug[0][0])
        meta.merge!({
          name: listing.title,
          description: listing.bio,
          image: listing.cover_image,
          image_width: '',
          image_height: ''
        })
      end
    elsif curated_list_slug.present?
      if curated_list = CuratedList.find_by(slug: curated_list_slug[0][0])
        meta.merge!({
          name: curated_list.name,
          description: curated_list.description,
        })
      end
    end

    generate_meta(meta)
  end

  private

  def self.generate_meta item
      item.each {|k, v| item[k] = CGI::escapeHTML(v || '')}

      "
        <title>#{name}</title>
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
