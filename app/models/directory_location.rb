# Defines a location that a user can search for (ie. city, province, county, etc)
class DirectoryLocation < ApplicationRecord
  validates :name, uniqueness: true

  acts_as_mappable

  def sync_location_details
    DirectoryLocation.build_locations lat, lng
  end

  def self.build_location address, type, details
    location = DirectoryLocation.find_by name: address

    params = {
      name: address,
      lat: details[:location]["lat"],
      lng: details[:location]["lng"],
      boundlat1: details[:bounds][:northeast]["lat"],
      boundlng1: details[:bounds][:northeast]["lng"],
      boundlat2: details[:bounds][:southwest]["lat"],
      boundlng2: details[:bounds][:southwest]["lng"],
      timezone: details[:timezone],
      city: details[:city] ? details[:city]["short_name"] : '',
      neighbourhood: details[:sublocality] ? details[:sublocality]["short_name"] : '',
      state: details[:state] ? details[:state]["short_name"] : '',
      country: details[:country]["short_name"],
      location_type: type
    }

    if !location
      location = DirectoryLocation.new(params)
    else
      location.update(params)
    end

    location
  end

  def self.build_locations lat, lng
    locations = []

    details = MapApi.build_from_coordinates lat, lng

    if !details.present?
      return []
    end

    if details[:city].present? and details[:state].present?
      name = "#{details[:city]["long_name"]}, #{details[:state]["short_name"]}"
      locations.append self.build_location(name, 'city', details)
    end

    if details[:sublocality].present? and details[:city].present?
      name = "#{details[:sublocality]["long_name"]}, #{details[:city]["long_name"]}"
      locations.append self.build_location(name, 'neighbourhood', details)
    end

    locations
  end

  def self.create_locations lat, lng
    locations = self.build_locations(lat, lng).compact
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
