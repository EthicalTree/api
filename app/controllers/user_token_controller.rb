class UserTokenController < Knock::AuthTokenController
  def create
    if !entity.confirmed_at
      render json: { error: 'user-not-confirmed' }
    else
      render json: auth_token, status: :created
    end
  end
end
