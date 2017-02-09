class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      AccountMailer.confirm_email(@user).deliver_later
      render 'sessions/confirm_email_sent'
    else
      render :new
    end
  end

  def resend_email_confirm
    @user = User.find_by confirm_token: params[:token]

    if @user
      AccountMailer.confirm_email(@user).deliver_later
      flash[:info] = "Confirmation email has been re-sent!"
      render :confirm_email_sent
    else
      redirect_to root_path
    end
  end

  def confirm_email
    @user = User.find_by confirm_token: params[:token]

    if @user
      flash[:info] = "Thanks for confirming! You can now log in below."
      @user.update confirmed_at: DateTime.current
      redirect_to login_path
    else
      redirect_to root_path
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

end