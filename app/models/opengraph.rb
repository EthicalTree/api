class Opengraph

  def initialize url
    @url = url
  end

  def get_meta_tags
    uri = URI(@url)

    if slug = uri.path.scan(/\/listings\/([\w-]+)\/?/)
      listing = Listing.find_by(slug: slug)
      get_meta_for_listing listing
    else
      ""
    end
  end

  private

  def get_meta_for_listing listing
    if listing.present?
      "
        <meta property=\"og:title\" content=\"#{listing.title}\" />
        <meta property=\"og:description\" content=\"#{listing.bio}\" />
        <meta property=\"og:image\" content=\"#{listing.cover_image}\" />
        <meta property=\"og:url\" content=\"#{@url}\" />
        <meta name=\"twitter:card\" content=\"summary_large_image\" />
      "
    else
      ""
    end
  end
end
