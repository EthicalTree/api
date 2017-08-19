class Listing < ApplicationRecord
  has_many :locations, dependent: :destroy

  has_many :listing_images
  has_many :listing_ethicalities

  has_many :images, through: :listing_images, class_name: 'Image'
  has_many :ethicalities, through: :listing_ethicalities, class_name: 'Ethicality'

  has_many :operating_hours, class_name: 'OperatingHours'

  before_validation :ensure_slug

  validates :title, presence: true
  validates :slug, uniqueness: true
  validates_length_of :bio, maximum: 2000, allow_blank: true

  @@search_fields = [
    'title',
    'bio'
  ]

  def self.search_fields
    return @@search_fields
  end

  def as_json_full options={}
    as_json({
      include: [
        :ethicalities,
        :images,
        :locations,
        {
          operating_hours: {
            methods: [:label, :hours, :open_str, :close_str, :enabled]
          }
        }
      ]
    })
  end

  def as_json_search options={}
    as_json({
      include: [
        :ethicalities,
        :images,
        :locations,
      ]
    })
  end

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

class ListingEthicality < ApplicationRecord
  belongs_to :listing
  belongs_to :ethicality
end

