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
    subject = "Claim Success - #{listing.title}"

    @ga_link = Links.ga({
      uid: @user.id,
      dp: '/email/listing_claimed',
      dt: subject,
    })

    mail(to: @user.email, subject: subject)
  end

end
