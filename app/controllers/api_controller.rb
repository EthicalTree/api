# frozen_string_literal: true

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

  def session_get(key)
    Rails.cache.fetch("#{current_user.id}_#{key}") if current_user
  end

  def session_set(key, value)
    Rails.cache.write("#{current_user.id}_#{key}", value) if current_user
  end

  def ip_location_information
    Session.session_location(remote_ip)
  end

  def ensure_admin
    raise Exceptions::NotAuthorized if !current_user || !current_user.admin?
  end
end
