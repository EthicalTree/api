class Listing < ApplicationRecord
  include Accessible

  has_many :locations, dependent: :destroy
  has_many :listing_images
  has_many :listing_ethicalities
  has_many :menus
  has_many :images, through: :listing_images, class_name: 'Image'
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

  # For now we only support one menu, but might support in the future
  def menu
    if self.menus.empty?
      self.menus = [Menu.create(title: '')]
      self.save
    end
    self.menus.first
  end

  def open_status time_zone
    hours = operating_hours.todays_hours time_zone

    if hours.present? && hours.open && hours.close
      hours.status time_zone
    else
      :closed
    end
  end

  def as_json_full options={}
    # make sure a menu is created if it doesn't exist
    self.menu

    result = as_json({
      include: [
        :ethicalities,
        :images,
        :locations,
        { menus: { include: [:images] } },
        { operating_hours: { methods: [
          :label, :hours, :open_str, :close_str, :enabled
        ]}},
      ]
    })

    if options[:location]
      with_location_fields result, options[:location]
    end
  end

  def as_json_search options={}
    result = as_json({
      include: [
        :ethicalities,
        :images,
        :locations,
      ]
    })

    if options[:location]
      with_location_fields result, options[:location]
    end
  end

  def with_location_fields listing, location
    listing.merge({
      open_status: open_status(location[:time_zone])
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

