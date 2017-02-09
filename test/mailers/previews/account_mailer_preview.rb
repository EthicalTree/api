class AccountMailerPreview < ActionMailer::Preview

  def confirm_email
    user = FactoryGirl.build :user
    AccountMailer.confirm_email user
  end

end