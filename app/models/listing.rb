class Listing < ApplicationRecord
  has_many :locations, dependent: :destroy
  has_many :ethicalities

  def jsonify
    return self.as_json include: [
      {
        locations: {
          include: :operating_hours
        }
      },
      :ethicalities
    ]
end
