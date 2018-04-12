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
    if listing.present?
      "
        <meta property=\"og:url\" content=\"#{@url}\">
        <meta property=\"og:title\" content=\"#{listing.title}\">
        <meta property=\"og:description\" content=\"#{listing.bio}\">
        <meta property=\"og:image\" content=\"#{listing.cover_image}\">
        <meta name=\"twitter:card\" content=\"summary_large_image\">
        <meta name=\"fb:app_id\" content=\"#{Rails.application.secrets[:fb_app_id]}\">
      "
    else
      ""
    end
  end

  def self.get_meta_for_curated_list curated_list
    if curated_list.present?
      "
        <meta property=\"og:url\" content=\"#{@url}\">
        <meta property=\"og:title\" content=\"#{curated_list.name}\">
        <meta property=\"og:description\" content=\"#{curated_list.description}\">
        <meta property=\"og:image\" content=\"#{curated_list._listings.first.cover_image}\">
        <meta name=\"twitter:card\" content=\"summary_large_image\">
        <meta name=\"fb:app_id\" content=\"#{Rails.application.secrets[:fb_app_id]}\">
      "
    else
      ""
    end
  end
end
