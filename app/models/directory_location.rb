# Defines a location that a user can search for (ie. city, province, county, etc)
class DirectoryLocation < ApplicationRecord
  validates :name, uniqueness: true

  acts_as_mappable

  def self.build_location address
    location = DirectoryLocation.find_by name: address

    if !location
      details = Map.build_from_address address

      location = DirectoryLocation.new({
        name: address,
        lat: details[:location]["lat"],
        lng: details[:location]["lng"],
        boundlat1: details[:bounds][0]["lat"],
        boundlng1: details[:bounds][0]["lng"],
        boundlat2: details[:bounds][1]["lat"],
        boundlng2: details[:bounds][1]["lng"],
      })
    end

    location
  end

  def self.build_locations lat, lng
    locations = []

    details = Map.build_from_coordinates lat, lng

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

end
