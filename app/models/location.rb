class Location < ApplicationRecord
  belongs_to :listing

  acts_as_mappable

  def formatted_address
    "#{address}, #{city}, #{region}"
  end
end
