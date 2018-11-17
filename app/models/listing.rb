class Listing < ApplicationRecord
  include Accessible
  include HasImages
  enum visibility: [:published, :unpublished]
  enum claim_status: [:unclaimed, :pending_verification, :claimed]

  has_one :plan
  has_many :locations, dependent: :destroy
  has_many :listing_images, dependent: :destroy
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
  belongs_to :directory_location, foreign_key: :directory_location_id, class_name: 'DirectoryLocation', optional: true

  before_validation :ensure_slug
  before_save :lower_website
  before_save :ensure_claim_id

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

  def regenerate_claim_id
    self.claim_id = SecureRandom.uuid
  end

  def cover_image
    images.first
  end

  def ethicalities_string
    ethicalities.map { |e| e.titleize }.join(', ')
  end

  def timezone
    if self.locations.length > 0
      self.locations.first.timezone
    else
      ''
    end
  end

  def address
    if self.locations.length > 0
      self.locations.first.formatted_address
    else
      ''
    end
  end

  def claim_url
    Links.listing_claim(self)
  end

  # For now we only support one menu, but might support in the future
  def menu
    if self.menus.empty?
      self.menus = [Menu.create(title: '')]
      self.save
    end
    self.menus.first
  end

  def city
    if directory_location then directory_location.city else "" end
  end

  def location
    locations.first
  end

  def set_location lat, lng
    location = Location.new lat: lat, lng: lng
    DirectoryLocation.create_locations lat, lng
    location.determine_location_details

    if location.city.present?
      directory_location, _ = Search.find_directory_location(
        location.city,
        is_city_scope: true
      )

      self.directory_location = directory_location
    end

    self.locations = [location]
  end

  def as_json_full
    # make sure a menu is created if it doesn't exist
    self.menu

    as_json({
      except: [:claim_id],
      include: [
        :categories,
        :ethicalities,
        :tags,
        :images,
        { locations: { methods: [:formatted_address] } },
        { plan: { methods: [:type] } },
        { menus: { include: [:images] } },
        { operating_hours: {
          methods: [
            :label,
            :open_at_24_hour,
            :closed_at_24_hour,
            :hours
          ]
        } },
      ],
      methods: [
        :address,
        :city,
        :location,
        :timezone
      ]
    })
  end

  def as_json_search
    as_json({
      only: [
        :id,
        :slug,
        :title
      ],
      except: [:claim_id],
      methods: [:city, :location, :timezone],
      include: [
        { ethicalities: { only: [
          :icon_key,
          :slug
        ] } },
        { images: { only: [
          :id,
          :key,
          :order
        ] } },
        { locations: { only: [
          :id,
          :lat,
          :lng
        ] } },
        { plan: { only: [
          :id
        ] } },
        { operating_hours: {
          only: [
            :day,
          ],
          methods: [
            :open_at_24_hour,
            :closed_at_24_hour
          ]
        } }
      ]
    })
  end

  def as_json_admin
    as_json({
      include: [
        { plan: { methods: [:type] } },
        :owner
      ],
      methods: [
        :claim_url
      ]
    })
  end

  private

  def ensure_slug
    if not self.slug
      self.slug = self.title.parameterize
    end
  end

  def ensure_claim_id
    if not self.claim_id
      self.regenerate_claim_id
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
