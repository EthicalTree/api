class Search

  def self.find_directory_location location
    specific_location = nil

    if !location.present?
      location = 'Ottawa'
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

    [directory_location, specific_location]
  end

  def self.by_location options={}
    results = options[:results]
    location = options[:location]
    radius = options[:radius] || 50

    directory_location, specific_location = Search.find_directory_location(location)

    if !directory_location.present?
      return nil
    end

    # Filter/Sort results
    coords = directory_location.coordinates

    if specific_location.present?
      coords = [specific_location[:lat], specific_location[:lng]]
      results = results.within(radius, units: :kms, origin: coords).reorder('distance ASC')
    else
      results = results.in_bounds(directory_location.bounds, origin: coords)
    end

    results
  end

end
