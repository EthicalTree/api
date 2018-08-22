class Session
  @@GEOSERVICES = [
    "http://api.ipstack.com/%s?access_key=#{Rails.application.secrets[:ipstack_api_key]}"
  ]

  attr_accessor :email, :password

  def self.session_location ip_address
    location_json = Rails.cache.fetch("ip_address_location/#{ip_address}", expires_in: 1.week) do
      res = HTTParty.get(@@GEOSERVICES[0] % ip_address)
      JSON.parse(res.body).to_json
    end

    r = JSON.parse(location_json)
    city = r['city'] || ''
    directory_location, _ = Search.find_directory_location(city)

    {
      city: directory_location ? directory_location.city : 'Toronto',
      directory_location: directory_location ? directory_location.name : 'Toronto, ON',
      latitude: r["latitude"],
      longitude: r["longitude"],
      time_zone: r["time_zone"]
    }
  rescue JSON::ParserError
    {}
  end

  def model_name
    'Session'
  end
end
