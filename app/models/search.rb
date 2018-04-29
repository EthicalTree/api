class Search

  def self.by_location options={}
    results = options[:results]
    location = options[:location]
    filtered = options[:filtered] || false
    by_radius = options[:by_radius] || false

    if location.present?
      directory_location = DirectoryLocation.find_by(name: location)

      if directory_location.present?
        coords = directory_location.coordinates
        results = results.by_distance(origin: coords)

        if filtered
          if by_radius
            results = results.within(5, units: :kms, origin: coords)
          else
            results = results.in_bounds(
              directory_location.bounds,
              origin: coords
            )
          end
        end
      else
        location = MapApi.build_from_address(location)[:location]
        coords = [location['lat'], location['lng']]
        results = results.by_distance(origin: coords)

        if filtered
          results = results.within(5, units: :kms, origin: coords)
        end
      end
    else
      coords = [location_information[:latitude], location_information[:longitude]]
      results = results.by_distance(origin: coords)

      if filtered
        results = results.within(5, units: :kms, origin: coords)
      end
    end

    results
  end

end
