class ListingLocation < ApplicationRecord
  belongs_to :listing
  belongs_to :location
  has_many :operating_hours
end
