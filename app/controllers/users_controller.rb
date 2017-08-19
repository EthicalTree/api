class UsersController < APIController
  before_action :authenticate_user, only: :show

  def new
    @user = User.new
  end

  def create
    if @user = User.where(email: user_params[:email], confirmed_at: nil).first
      @user.attributes = {password: '', password_confirmation: '', password_digest: ''}
      @user.attributes = user_params
      @user.regenerate_token
    else
      @user = User.new user_params
    end

    if @user.save
      AccountMailer.confirm_email(@user).deliver_later
      render json: {}, status: :ok
    else
      render json: { errors: @user.errors.full_messages }
    end
  end

  def confirm_email
    @user = User.find_by confirm_token: params[:token]

    if @user
      @user.update confirmed_at: DateTime.current
      render json: {}, status: :ok
    else
      render json: { errors: ["That's not the right token!"] }
    end

  end

  def show
    if params[:id] == 'current'
      render json: {
        user: current_user.to_json
      }
    end
  end

  def get_location
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :first_name,
      :last_name
    )
  end

end
