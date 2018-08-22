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

  def ip_location_information
      Session.session_location(remote_ip)
  end

  def ensure_admin
    if !current_user || !current_user.admin?
      raise ApplicationController::NotAuthorized
    end
  end
end
