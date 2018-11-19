class StatusController < APIController
  def index
    render json: { status: 'We\'re good!' }, status: 200
  end
end
