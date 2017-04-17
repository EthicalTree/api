class Location < ApplicationRecord
  has_many :listing_locations, dependant: true
  has_many :listings, through: :listing_locations

  acts_as_mappable
end
