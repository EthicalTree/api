class Location < ApplicationRecord
  belongs_to :listing

  acts_as_mappable

  def self.listings
    Location.all.joins(
      "INNER JOIN listings ON listings.id = locations.listing_id AND listings.visibility = 0",
    )
  end

  def formatted_address
    "#{address}, #{city}, #{region}"
  end

end
