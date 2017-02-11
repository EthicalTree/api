class SessionsController < ApplicationController

  def new
    @session = Session.new
  end

  def create
    session = session_params
    @user = User.find_by(email: session[:email]).try(:authenticate, session[:password])

    if @user
      if @user.confirmed?
        view_context.log_in @user
        redirect_to root_path
      else
        redirect_to pending_confirmation_path(email: @user.email)
      end
    else
      @login_error = 'Invalid email/password'
      render :new
    end
  end

  def destroy
    view_context.log_out
    redirect_to root_path
  end
private

  def session_params
    params.require(:session).permit :email, :password
  end

end