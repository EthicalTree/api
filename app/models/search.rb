class Search

  def self.by_location options={}
    results = options[:results]
    location = options[:location]
    filtered = options[:filtered] || false
    radius = options[:radius] || 5

    if location.present?
      directory_location = DirectoryLocation.find_by(name: location)

      if directory_location.present?
        coords = directory_location.coordinates

        if filtered
          results = results.within(radius, units: :kms, origin: coords)
        else
          results = results.by_distance(origin: coords)
        end
      else
        location = MapApi.build_from_address(location)[:location]
        coords = [location['lat'], location['lng']]
        results = results.by_distance(origin: coords)

        if filtered
          results = results.within(radius, units: :kms, origin: coords)
        end
      end
    else
      #coords = [location_information[:latitude], location_information[:longitude]]
      location = MapApi.build_from_address("Ottawa, ON")[:location]
      coords = [location['lat'], location['lng']]
      results = results.by_distance(origin: coords)

      if filtered
        results = results.within(radius, units: :kms, origin: coords)
      end
    end

    results
  end

end
