FactoryGirl.define do
  factory :user do
    email Faker::Internet.safe_email
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    password 'awesomepassword1'
    password_confirmation 'awesomepassword1'
    confirmed_at Time.now
  end
end