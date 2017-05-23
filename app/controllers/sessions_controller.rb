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
        render json: {}, status: :ok
      end
    else
      render json: { error: true, msg: 'Invalid email/password' }, status: :ok
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
