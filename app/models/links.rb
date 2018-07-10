class Links

  @@protocol = Rails.application.secrets[:protocol]
  @@webhost = Rails.application.secrets[:webhost]

  def self.get_link path
    "#{@@protocol}://#{@@webhost}#{path}"
  end

  def self.listing listing
    city = listing.city.present? ? listing.city : '_'
    Links.get_link("/listings/#{city}/#{listing.slug}")
  end

end
