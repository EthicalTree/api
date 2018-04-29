class Category < ApplicationRecord
  has_many :listing_categories
  has_many :listings, through: :listing_categories, class_name: 'Listing'

  validates :slug, uniqueness: true
  validates :name, uniqueness: true

  before_validation :ensure_slug

  private

  def ensure_slug
    if not self.slug
      self.slug = self.name.parameterize
    end
  end
end

class ListingCategory < ApplicationRecord
  belongs_to :listing
  belongs_to :category
end
