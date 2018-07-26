class APIController < ActionController::API
  include Response
  include ExceptionHandler
  include Knock::Authenticable

  def not_found
    render status: 404
  end

  def remote_ip
    if Rails.env == 'development'
      Rails.cache.fetch('development/ip_address') do
        HTTParty.get('https://canihazip.com/s').body
      end
    else
      request.remote_ip
    end
  end

  def session_get(key)
    if current_user
      Rails.cache.fetch("#{current_user.id}_#{key}")
    end
  end

  def session_set(key, value)
    if current_user
      Rails.cache.write("#{current_user.id}_#{key}", value)
    end
  end

  def set_location_information(addr)
    session_set('browser_latitude', addr.latitude)
    session_set('browser_longitude', addr.longitude)
    session_set('browser_city', addr.city)
  end

  def location_information
    {
      lat: session_get('browser_latitude'),
      lng: session_get('browser_longitude'),
      city: session_get('browser_city'),
    }
  end
end
