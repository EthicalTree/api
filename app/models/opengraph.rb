class Opengraph

  def self.get_meta_tags url
    @url = url
    uri = URI(@url)

    listing_slug = uri.path.scan(/\/listings\/([\w-]+)\/?/)
    curated_list_slug = uri.path.scan(/\/collections\/([\w-]+)\/?/)

    if listing_slug.present?
      listing = Listing.find_by(slug: listing_slug)
      get_meta_for_listing listing
    elsif curated_list_slug.present?
      curated_list = CuratedList.find_by(slug: curated_list_slug)
      get_meta_for_curated_list curated_list
    else
      ""
    end
  end

  private

  def self.get_meta_for_listing listing
    self.generate_meta listing do |item|
      {
        name: listing.title,
        description: listing.bio,
        image: listing.cover_image
      }
    end
  end

  def self.get_meta_for_curated_list curated_list
    self.generate_meta curated_list do |item|
      {
        name: curated_list.name,
        description: curated_list.description,
        image: curated_list._listings.first.cover_image
      }
    end
  end

  def self.generate_meta item
    if item.present?
      options = yield(item)
      options.each {|k, v| options[k] = CGI::escapeHTML(v)}

      "
        <meta property=\"og:url\" content=\"#{@url}\">
        <meta property=\"og:title\" content=\"#{options[:name]}\">
        <meta property=\"og:description\" content=\"#{options[:description]}\">
        <meta property=\"og:image\" content=\"#{options[:image]}\">
        <meta name=\"twitter:card\" content=\"summary_large_image\">
        <meta name=\"fb:app_id\" content=\"#{Rails.application.secrets[:fb_app_id]}\">
      "
    else
      ""
    end
  end
end