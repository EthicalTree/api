# frozen_string_literal: true

class Session
  def self.session_location lat, lng
    results = Geocoder.search([lat, lng])
    results.first
  end

  def model_name
    'Session'
  end
end
