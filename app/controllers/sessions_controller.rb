class SessionsController < APIController

  def index
    logger.info request.env
    render json: {
      ip_address: remote_ip,
      location: location_information
    }, status: 200
  end

end
