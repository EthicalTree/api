class SessionsController < APIController
  def index
    render json: {
      ip_address: remote_ip,
    }, status: 200
  end
end
