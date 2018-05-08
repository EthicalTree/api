FactoryBot.define do
  factory :listing do
    title { Faker::Company.name }
    bio { Faker::Company.catch_phrase }
  end
end
