class Listing < ApplicationRecord
  has_many :locations, dependent: :destroy
  has_many :ethicalities

  has_many :listing_images
  has_many :images, through: :listing_images, class_name: 'Image'

  before_validation :ensure_slug

  validates :title, presence: true
  validates :slug, uniqueness: true

  private

  def ensure_slug
    if not self.slug
      self.slug = self.title.parameterize
    end
  end
end

class ListingImage < ApplicationRecord
  belongs_to :listing
  belongs_to :image

end
