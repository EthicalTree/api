class AccountMailer < ApplicationMailer

  def confirm_email user
    @user = user
    mail(to: @user.email, subject: 'Confirm your email')
  end

  def forgot_password user
    @user = user
    mail(to: @user.email, subject: 'Forgot your password')
  end

end
