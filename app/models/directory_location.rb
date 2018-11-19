# Defines a location that a user can search for (ie. city, province, county, etc)
class DirectoryLocation < ApplicationRecord
  validates :name, uniqueness: true
  has_many :listings

  acts_as_mappable

  def get_city
    if location_type == 'city'
      self
    else
      DirectoryLocation.find_by(city: self.city, location_type: 'city')
    end
  end

  def format_address
    if location_type == 'neighbourhood'
      "#{neighbourhood}, #{city}, #{state}, #{country}"
    elsif location_type == 'city'
      "#{city}, #{state}, #{country}"
    else
      "#{name}"
    end
  end

  def sync_location_details
    details = MapApi.build_from_address format_address
    DirectoryLocation.build_location name, location_type, details
  end

  # `location` can be a:
  #   String - '{lat},{lng}'
  #   String - '{cityname}'
  #   String - '{location_name}'
  def self.find_by_location location
    if latlng_location = LatLng::parse(location)
      directory_location = DirectoryLocation.by_distance(origin: [latlng_location[:lat], latlng_location[:lng]]).first
    elsif directory_location = DirectoryLocation.find_by(id: location)
    elsif directory_location = DirectoryLocation.find_by('lower(name)=?', location)
    elsif directory_location = DirectoryLocation.find_by('lower(city)=? AND location_type="city"', location)
    elsif directory_location = DirectoryLocation.find_by('lower(neighbourhood)=? AND location_type="neighbourhood"', location)
    end

    [directory_location, latlng_location]
  end

  def self.get_neighborhoods_for_city city
    DirectoryLocation.where(
      "city = ? AND location_type = 'neighbourhood'",
      city
    ).includes(:listings)
  end

  def self.build_location address, type, details
    location = DirectoryLocation.find_by name: address

    if (!details.present?)
      return location
    end

    params = {
      name: address,
      timezone: details[:timezone],
      city: details[:city],
      neighbourhood: details[:sublocality],
      state: details[:state],
      country: details[:country],
      location_type: type
    }

    if !location
      location = DirectoryLocation.new(params.merge({
        lat: details[:location]["lat"],
        lng: details[:location]["lng"],
        boundlat1: details[:bounds][:northeast]["lat"],
        boundlng1: details[:bounds][:northeast]["lng"],
        boundlat2: details[:bounds][:southwest]["lat"],
        boundlng2: details[:bounds][:southwest]["lng"],
      }))
    else
      location.update(params)
    end

    location
  end

  def self.build_locations details
    locations = []

    if !details.present?
      return []
    end

    if details[:city].present? and details[:state].present?
      name = "#{details[:city]}, #{details[:state]}"
      city_details = MapApi.build_from_address(name)
      locations.append self.build_location(name, 'city', city_details)
    end

    if details[:sublocality].present? and details[:city].present?
      name = "#{details[:sublocality]}, #{details[:city]}"
      neighbourhood_details = MapApi.build_from_address(name)
      locations.append self.build_location(name, 'neighbourhood', neighbourhood_details)
    end

    locations
  end

  def self.build_locations_for_lat_lng lat, lng
    DirectoryLocation.build_locations MapApi.build_from_coordinates lat, lng
  end

  def self.build_locations_for_address address
    DirectoryLocation.build_locations MapApi.build_from_address address
  end

  def self.create_locations lat, lng
    locations = self.build_locations_for_lat_lng(lat, lng).compact
    locations.each { |l| l.save }
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
