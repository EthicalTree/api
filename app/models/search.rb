class Search

  def self.by_location options={}
    results = options[:results]
    location = options[:location]
    filtered = options[:filtered] || false
    radius = options[:radius] || 50

    if location.present?
      location = location.downcase

      if directory_location = DirectoryLocation.find_by('lower(name)=?', location)
      elsif directory_location = DirectoryLocation.find_by('lower(city)=? AND location_type="city"', location)
      elsif directory_location = DirectoryLocation.find_by('lower(neighbourhood)=? AND location_type="neighbourhood"', location)
      end

      if directory_location.present?
        coords = directory_location.coordinates
      else
        location = MapApi.build_from_address(location)[:location]
        coords = [location['lat'], location['lng']]
      end
    else
      #coords = [location_information[:latitude], location_information[:longitude]]
      location = MapApi.build_from_address("Ottawa, ON")[:location]
      coords = [location['lat'], location['lng']]
    end

    if filtered
      results = results.within(radius, units: :kms, origin: coords)
    else
      results = results.by_distance(origin: coords)
    end

    results
  end

end
