class Location < ApplicationRecord
  belongs_to :listing
  has_many :operating_hours, class_name: 'OperatingHours'

  acts_as_mappable
end
