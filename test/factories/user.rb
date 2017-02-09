FactoryGirl.define do
  factory :user do
    email Faker::Internet.safe_email
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    password 'awesomepassword1'
    password_confirmation 'awesomepassword1'
    confirmed_at Time.now
    confirm_token SecureRandom.urlsafe_base64.to_s
  end
end