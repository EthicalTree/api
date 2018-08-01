class UsersController < APIController
  before_action :authenticate_user, only: :show

  def create
    claim_listing_slug = params[:claim_listing_slug]
    claim_id = params[:claim_id]

    if @user = User.where(email: user_params[:email]).first
      @user.attributes = {password: '', password_confirmation: '', password_digest: ''}
      @user.attributes = user_params
      @user.regenerate_token
    else
      @user = User.new user_params
    end

    if claim_listing_slug.present?
      if listing = Listing.find_by(slug: claim_listing_slug)
        if ['pending_verification', 'claimed'].include? listing.claim_status
          @user.errors.add(:base, 'Sorry, this listing has already been claimed.')
        else
          @user.confirmed_at = DateTime.current
          @user.save

          listing.owner = @user

          if claim_id == listing.claim_id
            listing.claim_status = :claimed
          else
            listing.claim_status = :pending_verification
          end

          listing.save

          AccountMailer.listing_claimed(@user, listing).deliver_later
        end
      end
    else
      if @user.save
        AccountMailer.confirm_email(@user).deliver_later
      end
    end

    if !@user.errors.any?
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

  def forgot_password
    if token = params[:token]
      @user = User.where.not(forgot_password_token: nil).find_by forgot_password_token: token

      if @user && params[:check]
        render json: { email: @user.email }, status: :ok
      elsif !@user
        render json: { errors: ["Not a valid confirmation token!"] }
      elsif @user.update_attributes(change_password_params)
        render json: {}, status: :ok
      else
        render json: { errors: @user.errors.full_messages }
      end
    else
      @user = User.find_by email: params[:email]

      if @user
        @user.regenerate_forgot_password_token
        AccountMailer.forgot_password(@user).deliver_later
        render json: {}, status: :ok
      else
        render json: { errors: ["Whoops! We can't find a user with that email address."] }
      end
    end
  end

  def show
    if params[:id] == 'current'
      render json: {
        user: current_user.as_json_basic
      }
    end
  end

  def update
    if params[:id] == 'current'
      @user = User.find_by(id: current_user.id)

      # Don't let user change password without providing user password first
      if (user_params[:password_confirmation] || user_params[:password]) && !@user.authenticate(params[:user][:current_password])
        render json: { errors: ["Specified password for current user is incorrect"] }
      else
        @user.update_attributes user_params

        if @user.save
          render json: {}, status: :ok
        else
          render json: { errors: @user.errors.full_messages }
        end
      end
    end
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

  def change_password_params
    params.permit(
      :password,
      :password_confirmation
    )
  end
end
