class Listing < ApplicationRecord
  has_many :locations, dependent: :destroy
  has_many :ethicalities
end
