require_dependency 'latlng'

module Search
  class << self

    def find_directory_location location, options={}
      if location.is_a?(Hash)
        return [nil, nil]
      end

      if location.is_a?(String)
        location = location.downcase
      end

      if !location.present?
        location = 'Toronto'
      end

      directory_location, latlng_location = DirectoryLocation.find_by_location(location)

      if !directory_location.present?
        location = MapApi.build_from_address(location)
        city = ''

        if location
          latlng_location = location[:latlng]
          city = location[:city]
        end

        directory_location = DirectoryLocation.find_by_location(city.downcase)
      end

      if options[:is_city_scope] && directory_location
        directory_location = directory_location.get_city
      end

      [directory_location, latlng_location]
    end

    def by_location options={}
      is_city_scope = options[:is_city_scope]
      location = options[:location]
      radius = options[:radius] || 50
      results = options[:results]

      directory_location, latlng_location = Search::find_directory_location(location, {
        is_city_scope: is_city_scope
      })

      if latlng_location.present?
        coords = [latlng_location[:lat], latlng_location[:lng]]
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
end
