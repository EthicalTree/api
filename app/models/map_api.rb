# frozen_string_literal: true

class MapApi
  FromCoordinatesUrl = 'https://maps.googleapis.com/maps/api/geocode/json'
  FromAddressUrl = 'https://maps.googleapis.com/maps/api/geocode/json'
  TimezoneUrl = 'https://maps.googleapis.com/maps/api/timezone/json'

  def self.parse_results(details)
    return nil unless details.present?

    bounds = details['geometry']['viewport']
    location = details['geometry']['location']

    extracted = details['address_components'].each_with_object({}) do |c, a|
      c['types'].each { |t| a[t.to_sym] = c }
    end

    latlng = { lat: location['lat'], lng: location['lng'] }

    {
      address: details['formatted_address'],
      country: extracted[:country] ? extracted[:country]['short_name'] : '',
      state: extracted[:administrative_area_level_1] ? extracted[:administrative_area_level_1]['short_name'] : '',
      city: extracted[:locality] ? extracted[:locality]['short_name'] : '',
      neighbourhood: extracted[:neighborhood] ? extracted[:neighborhood]['short_name'] : '',
      sublocality: extracted[:sublocality] ? extracted[:sublocality]['short_name'] : '',
      bounds: {
        northeast: bounds['northeast'],
        southwest: bounds['southwest']
      },
      location: location,
      latlng: latlng,
      timezone: get_timezone_details(location['lat'], location['lng'])
    }
  end

  def self.build_from_coordinates(lat, lng)
    get_location_details "#{FromCoordinatesUrl}?latlng=#{lat},#{lng}"
  end

  def self.build_from_address(address)
    get_location_details "#{FromAddressUrl}?address=#{address}"
  end

  def self.get_timezone_details(lat, lng)
    key = Rails.application.secrets.gmaps_api_key
    timestamp = Timezone.now.to_i
    url = "#{TimezoneUrl}?location=#{lat},#{lng}&timestamp=#{timestamp}&key=#{key}"
    res = HTTParty.get(URI.parse(URI.encode(url.to_s)))
    JSON.parse(res.body)['timeZoneId']
  end

  def self.get_location_details(url)
    key = Rails.application.secrets.gmaps_api_key
    res = HTTParty.get(URI.parse(URI.encode("#{url}&key=#{key}")))
    body = JSON.parse(res.body)

    raise body['error_message'] if body['error_message']

    details = body['results'][0]
    MapApi.parse_results details
  end
end
