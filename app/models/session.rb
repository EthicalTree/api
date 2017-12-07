class Session
  @@GEOSERVICES = [
    'https://freegeoip.net/json/%s'
  ]

  attr_accessor :email, :password

  def self.session_location ip_address
    location_json = Rails.cache.fetch("ip_address_location/#{ip_address}", expires_in: 1.week) do
      res = HTTParty.get(@@GEOSERVICES[0] % ip_address)
      JSON.parse(res.body).to_json
    end

    r = JSON.parse(location_json)

    {
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
