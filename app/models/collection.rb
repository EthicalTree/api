class Collection < ApplicationRecord
  include HasImages

  enum location: [:front_page]

  belongs_to :tag
  after_save :ensure_unique_order
  before_save :ensure_slug

  has_many :collection_images
  has_many :images, through: :collection_images, class_name: 'Image'

  validates :name, presence: true
  validates :tag, presence: true
  validates :slug, uniqueness: true

  def _listings(options={})
    count = options[:count] || 6
    is_city_scope = options[:is_city_scope]
    location = options[:location]

    listings = Location.listings.joins(
      "INNER JOIN listing_tags ON listings.id = listing_tags.listing_id"
    ).where(
      'listing_tags.tag_id': tag_id
    )

    search_listings = Search.by_location({
      is_city_scope: is_city_scope,
      results: listings,
      location: location,
    })

    if search_listings
      listings = search_listings
    end

    listings = listings.order(
      'RAND()'
    ).limit(count)

    listings
  end

  def cover_image
    self.images.first
  end

  def hashtag
    self.tag ? self.tag.hashtag : ''
  end

  def listings
    listings, _ = self._listings
    listings.map {|l| l.as_json_search}
  end

  def serializable_hash options={}
    super({
      methods: [
        :cover_image,
        :hashtag
      ]
    }.merge(options))
  end

  def as_json_full
    as_json({
      include: [
        :tag,
        :images
      ],
    })
  end

  private

  def ensure_unique_order
    Collection.all.order(:order).each_with_index do |cl, i|
      cl.update_column(:order, i+1)
    end
  end

  def ensure_slug
    self.slug = self.name.parameterize separator: '-'
  end
end

class CollectionImage < ApplicationRecord
  belongs_to :collection
  belongs_to :image
end


