class AccountMailer < ApplicationMailer

  def confirm_email user
    @user = user
    mail(to: @user.email, subject: 'Confirm your email')
  end

  def forgot_password user
    @user = user
    mail(to: @user.email, subject: 'Forgot your password')
  end

  def listing_claimed user, listing
    @user = user
    @listing = listing
    mail(to: @user.email, subject: 'Thanks for claiming your listing')
  end

end
