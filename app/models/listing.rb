class Listing < ApplicationRecord
  include Accessible

  enum visibility: [:published, :unpublished]

  has_one :plan
  has_many :locations, dependent: :destroy
  has_many :listing_images
  has_many :listing_ethicalities
  has_many :listing_tags
  has_many :menus
  has_many :images, through: :listing_images, class_name: 'Image'
  has_many :tags, through: :listing_tags, class_name: 'Tag'
  has_many :ethicalities, through: :listing_ethicalities, class_name: 'Ethicality'
  has_many :operating_hours, class_name: 'OperatingHours'

  belongs_to :owner, foreign_key: :owner_id, class_name: 'User'

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

  def featured_listings
    if !plan.present?
      Plan.featured_listings.map {|l| l.as_json_search}
    else
      []
    end
  end

  # For now we only support one menu, but might support in the future
  def menu
    if self.menus.empty?
      self.menus = [Menu.create(title: '')]
      self.save
    end
    self.menus.first
  end

  def open_status
    location = locations.first

    if location
      hours = operating_hours.todays_hours location.timezone

      if hours.present? && hours.open && hours.close
        hours.status location.timezone
      else
        :closed
      end
    else
      :closed
    end
  end

  def as_json_full options={}
    # make sure a menu is created if it doesn't exist
    self.menu

    as_json({
      include: [
        :ethicalities,
        :tags,
        :images,
        :locations,
        { plan: { methods: [:type] } },
        { menus: { include: [:images] } },
        { operating_hours: { methods: [
          :label, :hours, :open_str, :close_str, :enabled
        ]}},
      ],
      methods: [
        :open_status,
        :featured_listings
      ]
    })
  end

  def as_json_search options={}
    as_json({
      include: [
        :ethicalities,
        :images,
        :locations,
      ],
      methods: [
        :open_status
      ]
    })
  end

  def as_json_admin options={}
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

