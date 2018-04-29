class Listing < ApplicationRecord
  include Accessible

  enum visibility: [:published, :unpublished]

  has_one :plan
  has_many :locations, dependent: :destroy
  has_many :listing_images
  has_many :listing_ethicalities
  has_many :listing_tags
  has_many :listing_categories
  has_many :menus
  has_many :images, through: :listing_images, class_name: 'Image'
  has_many :tags, through: :listing_tags, class_name: 'Tag'
  has_many :categories, through: :listing_categories, class_name: 'Category'
  has_many :ethicalities, through: :listing_ethicalities, class_name: 'Ethicality'
  has_many :operating_hours, class_name: 'OperatingHours'

  belongs_to :owner, foreign_key: :owner_id, class_name: 'User', optional: true

  before_validation :ensure_slug
  before_save :lower_website

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

  def cover_image
    image = images.first
    key = if image.present? then image.key else '/defaults/opengraph-ethicaltree.png' end
    "https://#{$s3_bucket}.s3.amazonaws.com/#{key}"
  end

  # For now we only support one menu, but might support in the future
  def menu
    if self.menus.empty?
      self.menus = [Menu.create(title: '')]
      self.save
    end
    self.menus.first
  end

  def as_json_full
    # make sure a menu is created if it doesn't exist
    self.menu

    as_json({
      include: [
        :ethicalities,
        :tags,
        :images,
        { locations: { methods: [:formatted_address] } },
        { plan: { methods: [:type] } },
        { menus: { include: [:images] } },
        { operating_hours: {
          methods: [
            :label
          ]
        }},
      ],
    })
  end

  def as_json_search
    as_json({
      only: [
        :id,
        :slug,
        :title
      ],
      include: [
        {ethicalities: {only: [
          :icon_key,
          :slug
        ]}},
        {images: {only: [
          :id,
          :key,
          :order
        ]}},
        {locations: {only: [
          :id,
          :lat,
          :lng
        ]}},
        {plan: {only: [
          :id
        ]}},
        {operating_hours: {only: [
          :day,
          :open,
          :close
        ]}}
      ]
    })
  end

  def as_json_admin
    as_json({
      include: [
        { plan: { methods: [:type] } }
      ]
    })
  end

  private

  def ensure_slug
    if not self.slug
      self.slug = self.title.parameterize
    end
  end

  def lower_website
    if self.website.present?
      self.website = self.website.downcase
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

class ListingTag < ApplicationRecord
  belongs_to :listing
  belongs_to :tag
end

class ListingCategory < ApplicationRecord
  belongs_to :listing
  belongs_to :category
end

