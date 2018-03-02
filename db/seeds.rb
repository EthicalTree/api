# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ethicalities = {
  'Vegetarian': 'vegetarian',
  'Vegan': 'vegan',
  'Woman Owned': 'woman_owned',
  'Fair Trade': 'fair_trade',
  'Organic': 'organic'
}

ethicalities.each do |name, icon_key|
  name = name.to_s
  slug = name.parameterize separator: '_'

  ethicality = Ethicality.find_by slug: slug

  if not ethicality
    Ethicality.create name: name, icon_key: icon_key
  else
    ethicality.assign_attributes name: name, icon_key: icon_key
    ethicality.save
  end
end

