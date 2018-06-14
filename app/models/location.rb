class Location < ApplicationRecord
  belongs_to :listing

  acts_as_mappable

  def self.listings
    Location.all.joins(
      "INNER JOIN listings ON listings.id = locations.listing_id AND listings.visibility = 0",
    )
  end

  def determine_location_details
    location_info = MapApi.build_from_coordinates(lat, lng)

    assign_attributes({
      address: location_info[:address],
      city: location_info[:city],
      country: location_info[:country],
      region: location_info[:state],
      timezone: location_info[:timezone]
    })

  end

  def formatted_address
    "#{address}, #{city}, #{region}"
  end

end
