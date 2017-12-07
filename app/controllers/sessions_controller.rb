class SessionsController < APIController

  def index
    render json: {
      ip_address: remote_ip,
      location: location_information
    }, status: 200
  end

end
