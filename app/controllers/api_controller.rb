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
      request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
    end
  end

  def location_information
    Session.session_location(remote_ip)
  end
end
