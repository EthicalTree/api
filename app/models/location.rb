class Location < ApplicationRecord
  belongs_to :listing

  acts_as_mappable
end
