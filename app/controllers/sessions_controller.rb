class SessionsController < ApplicationController

  def new
    @session = Session.new
  end

  def create
    session = session_params

    if User.find_by(email: session[:email]).try(:authenticate, session[:password]).try(:confirmed?)
      redirect_to root_path
    else
      flash[:login] = 'Invalid email/password'
      render :new
    end
  end

  def destroy

  end
private

  def session_params
    params.require(:session).permit :email, :password
  end

end