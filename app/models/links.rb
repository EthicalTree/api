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

  def self.listing_claim listing
    "#{Links.listing(listing)}?claim=true&claimId=#{listing.claim_id}"
  end

  def self.ga options
    query = {
      v: 1,
      tid: Rails.application.secrets[:ga_code],
      t: 'event',
      ea: 'open',
    }.merge(options)

    "https://www.google-analytics.com/collect?#{query.to_query}"
  end
end
