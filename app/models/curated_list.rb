class CuratedList < ApplicationRecord
  enum location: [:front_page]

  belongs_to :tag
  after_save :ensure_unique_order

  validates :name, presence: true
  validates :tag, presence: true

  def listings
    Listing.joins(
      "INNER JOIN listing_tags ON listings.id = listing_tags.listing_id"
    ).where('listing_tags.tag_id': tag_id).order('RAND()').limit(8).map do |l|
      l.as_json_search
    end.shuffle
  end

  private

  def ensure_unique_order
    CuratedList.all.order(:order).each_with_index do |cl, i|
      cl.update_column(:order, i+1)
    end
  end
end
