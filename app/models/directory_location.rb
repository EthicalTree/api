# Defines a location that a user can search for (ie. city, province, county, etc)
class DirectoryLocation < ApplicationRecord
  validates :name, uniqueness: true
  validates :timezone, presence: true

  acts_as_mappable

  def self.build_location address
    location = DirectoryLocation.find_by name: address

    if !location
      details = MapApi.build_from_address address

      location = DirectoryLocation.new({
        name: address,
        lat: details[:location]["lat"],
        lng: details[:location]["lng"],
        boundlat1: details[:bounds][:northeast]["lat"],
        boundlng1: details[:bounds][:northeast]["lng"],
        boundlat2: details[:bounds][:southwest]["lat"],
        boundlng2: details[:bounds][:southwest]["lng"],
        timezone: details[:timezone]
      })
    end

    location
  end

  def self.build_locations lat, lng
    locations = []

    details = MapApi.build_from_coordinates lat, lng

    if details[:city].present? and details[:state].present?
      name = "#{details[:city]["long_name"]}, #{details[:state]["short_name"]}"
      locations.append self.build_location(name)
    end

    if details[:sublocality].present? and details[:city].present?
      name = "#{details[:sublocality]["long_name"]}, #{details[:city]["long_name"]}"
      locations.append self.build_location(name)
    end

    locations
  end

  def self.create_locations lat, lng
    locations = self.build_locations lat, lng
    locations.each {|l| l.save}
  end

  def coordinates
    [lat, lng]
  end

  def bounds
    Geokit::Bounds.new(
      Geokit::LatLng.new(boundlat2, boundlng2),
      Geokit::LatLng.new(boundlat1, boundlng1)
    )
  end

end
