class Search

  def self.find_directory_location location, options={}
    specific_location = nil

    if location.is_a?(Hash)
      return [nil, nil]
    end

    if !location.present?
      location = 'Toronto'
    end

    # Get a DirectoryLocation object
    location = location.downcase
    directory_location = DirectoryLocation.find_by_location(location)

    if !directory_location.present?
      location = MapApi.build_from_address(location)
      city = ''

      if location
        specific_location = location[:latlng]
        city = location[:city]
      end

      directory_location = DirectoryLocation.find_by_location(city.downcase)
    end

    if options[:is_city_scope] && directory_location
      directory_location = directory_location.get_city
    end

    [directory_location, specific_location]
  end

  def self.by_location options={}
    is_city_scope = options[:is_city_scope]
    location = options[:location]
    radius = options[:radius] || 50
    results = options[:results]

    # if location is a latlng string then use it as a specific location
    specific_location = LatLng.parse(location)
    directory_location = nil

    if !specific_location
      directory_location, specific_location = Search.find_directory_location(location, {
        is_city_scope: is_city_scope
      })
    end

    if specific_location.present?
      coords = [specific_location[:lat], specific_location[:lng]]
      results = results.within(radius, units: :kms, origin: coords).reorder('distance ASC')
    else
      if location.is_a?(Hash)
        swlat, swlng, nelat, nelng = location.values_at(:swlat, :swlng, :nelat, :nelng)
        sw = Geokit::LatLng.new(swlat, swlng)
        ne = Geokit::LatLng.new(nelat, nelng)
        bounds = Geokit::Bounds.new(sw, ne)
      elsif directory_location.present?
        bounds = directory_location.bounds
      else
        return nil
      end

      results = results.in_bounds(bounds)
    end

    results
  end

end
