class Listing < ApplicationRecord
  has_many :listing_locations, dependant: true
  has_many :locations, through: :listing_locations
  has_many :listing_ethicalities
end
