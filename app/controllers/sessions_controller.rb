class SessionsController < APIController

  def index
    render json: {
      x_forwarded_for: request.env['HTTP_X_FORWARDED_FOR'],
      x_original_forwarded_for: request.env['HTTP_X_ORIGINAL_FORWARDED_FOR'],
      ip_address: remote_ip,
      location: location_information
    }, status: 200
  end

end
