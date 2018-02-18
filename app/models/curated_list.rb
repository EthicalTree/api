class CuratedList < ApplicationRecord
  enum location: [:front_page]

  belongs_to :tag

  validates :name, presence: true
  validates :tag, presence: true

  def listings
    Listing.where tag: tag
  end
end
