class SessionsController < APIController

  def index
    render json: {
      ip_address: remote_ip,
      location: location_information
    }, status: 200
  end

  def set_location
    lat = params[:lat]
    lng = params[:lng]

    addr = Session.session_location(lat, lng)

    set_location_information(addr)

    render json: {location: location_information}, status: :ok
  end

end
