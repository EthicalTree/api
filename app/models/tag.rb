class Tag < ApplicationRecord
  enum use_type: [:category, :admin]
  after_initialize :strip_hashes

  has_many :listing_tags
  has_many :listings, through: :listing_tags, class_name: 'Listing'
  has_many :collections

  validates :hashtag, uniqueness: true
  validates :hashtag, presence: true

  def as_json_admin
    as_json({
              only: [
                :id,
                :hashtag,
                :use_type
              ],
              methods: :listing_count
            })
  end

  def listing_count
    listings.count
  end

  def strip_hashes
    self.hashtag = self.class.strip_hashes(self.hashtag)
  end

  def formatted_hashtag
    "##{hashtag}"
  end

  def self.strip_hashes(text)
    text.remove(/[#\s]/).downcase
  end
end

class ListingTag < ApplicationRecord
  belongs_to :listing
  belongs_to :tag
end
