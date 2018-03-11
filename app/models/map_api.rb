class MapApi

  FromCoordinatesUrl = "https://maps.googleapis.com/maps/api/geocode/json"
  FromAddressUrl = "https://maps.googleapis.com/maps/api/geocode/json"
  TimezoneUrl = "https://maps.googleapis.com/maps/api/timezone/json"

  def self.parse_results details
    if !details.present?
      return nil
    end

    bounds = details["geometry"]["viewport"]
    location = details["geometry"]["location"]
    extracted = details["address_components"].reduce({}) do |a, c|
      c["types"].each {|t| a[t.to_sym] = c}
      a
    end

    {
      country: extracted[:country],
      state: extracted[:administrative_area_level_1],
      city: extracted[:locality],
      neighbourhood: extracted[:neighborhood],
      sublocality: extracted[:sublocality],
      bounds: {
        northeast: bounds["northeast"],
        southwest: bounds["southwest"]
      },
      location: location,
      timezone: self.get_timezone_details(location["lat"], location["lng"])
    }
  end

  def self.build_from_coordinates lat, lng
    self.get_location_details "#{FromCoordinatesUrl}?latlng=#{lat},#{lng}"
  end

  def self.build_from_address address
    self.get_location_details "#{FromAddressUrl}?address=#{address}"
  end

  def self.get_timezone_details lat, lng
    key = Rails.application.secrets.gmaps_api_key
    timestamp = Timezone.now.to_i
    url = "#{TimezoneUrl}?location=#{lat},#{lng}&timestamp=#{timestamp}&key=#{key}"
    res = HTTParty.get(URI.parse(URI.encode("#{url}")))
    JSON.parse(res.body)["timeZoneId"]
  end

  def self.get_location_details url
    key = Rails.application.secrets.gmaps_api_key
    res = HTTParty.get(URI.parse(URI.encode("#{url}&key=#{key}")))
    details = JSON.parse(res.body)["results"][0]
    MapApi.parse_results details
  end

end
