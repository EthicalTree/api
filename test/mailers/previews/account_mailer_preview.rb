class AccountMailerPreview < ActionMailer::Preview

  def confirm_email
    user = FactoryBot.build :user
    AccountMailer.confirm_email user
  end

end
