class Search

  def self.by_location results, location

    if location.present?
      directory_location = DirectoryLocation.find_by(name: location)

      if directory_location.present?
        coords = directory_location.coordinates

        results = results.by_distance(origin: coords).in_bounds(
          directory_location.bounds,
          origin: coords
        )
      else
        location = MapApi.build_from_address(location)[:location]
        coords = [location['lat'], location['lng']]
        results = results.within(5, units: :kms, origin: coords)
      end
    else
      coords = [location_information[:latitude], location_information[:longitude]]
      results = results.within(5, units: :kms, origin: coords)
    end

    results
  end

end
