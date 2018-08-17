class APIController < ActionController::API
  include Response
  include ExceptionHandler
  include Knock::Authenticable

  def remote_ip
    if Rails.env == 'development'
      Rails.cache.fetch('development/ip_address') do
        HTTParty.get('https://canihazip.com/s').body
      end
    else
      request.remote_ip
    end
  end

  def location_information
    Session.session_location(remote_ip)
  end

  def ensure_admin
    if !current_user || !current_user.admin?
      raise Exceptions::NotAuthorized
    end
  end
end
