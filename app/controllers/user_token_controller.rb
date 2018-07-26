class UserTokenController < Knock::AuthTokenController
  def create
    if !entity.confirmed_at
      render json: { errors: ["User has not confirmed their email address"] }
    else
      render json: auth_token, status: :created
    end
  end
end
