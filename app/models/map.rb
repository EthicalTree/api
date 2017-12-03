class Map

  def self.parse_results details
    bounds = details["geometry"]["viewport"]
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
      location: details["geometry"]["location"]
    }
  end

  def self.build_from_coordinates lat, lng
    key = Rails.application.secrets.gmaps_api_key
    url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}&key=#{key}"
    res = HTTParty.get(URI.parse(URI.encode(url)))
    details = JSON.parse(res.body)["results"][0]

    Map.parse_results details
  end

  def self.build_from_address address
    key = Rails.application.secrets.gmaps_api_key
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key=#{key}"
    res = HTTParty.get(URI.parse(URI.encode(url)))
    details = JSON.parse(res.body)["results"][0]

    Map.parse_results details
  end

end
