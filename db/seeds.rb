# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ethicalities = [
  'Vegetarian',
  'Vegan',
  'Fair Trade',
  'Cat Owned',
  'No Martian Slaves'
]

# create x number of random listings
x = ENV['listings']
if x
  x.to_i.times do
    l = Listing.new title: Faker::Company.name, bio: Faker::Lorem.words(rand(25..75))

    l.ethicalities = ethicalities.sample(rand(1..5)).map do |e|
      Ethicality.new name: e
    end

  end
end
