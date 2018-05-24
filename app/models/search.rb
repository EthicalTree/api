class Search

  def self.find_directory_location location
    if directory_location = DirectoryLocation.find_by('lower(name)=?', location)
    elsif directory_location = DirectoryLocation.find_by('lower(city)=? AND location_type="city"', location)
    elsif directory_location = DirectoryLocation.find_by('lower(neighbourhood)=? AND location_type="neighbourhood"', location)
    end
    directory_location
  end

  def self.by_location options={}
    results = options[:results]
    location = options[:location]
    filtered = options[:filtered] || false
    radius = options[:radius] || 50

    if !location.present?
      location = 'Ottawa'
    end

    # Get a DirectoryLocation object
    location = location.downcase
    directory_location = Search.find_directory_location(location)

    if !directory_location.present?
      location = MapApi.build_from_address(location)
      city = location ? location[:city] : ''
      directory_location = Search.find_directory_location(city.downcase)
    end

    if !directory_location.present?
      return [results, nil]
    end

    # Filter/Sort results
    coords = directory_location.coordinates

    if filtered
      results = results.within(radius, units: :kms, origin: coords)
    else
      results = results.by_distance(origin: coords)
    end

    [results, directory_location]
  end

end
