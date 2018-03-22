class Plan < ApplicationRecord
  belongs_to :listing

  def self.Types
    {
      trial: { name: 'Trial', price: 0.00 },
      premium: { name: 'Premium', price: 57.00 },
      bronze: { name: 'Bronze', price: 69.00 },
      silver: { name: 'Silver', price: 129.00 },
      gold: { name: 'Gold', price: 189.00 }
    }
  end

  def self.featured_listings
    if list = CuratedList.find_by(featured: true)
      list.tag.listings.order('RAND()').limit(4).shuffle
    else
      Plan.all.order('RAND()').limit(4).map do |p|
        p.listing
      end.shuffle
    end
  end

  validates :listing_id, presence: true
  validates :plan_type, presence: true, inclusion: {
    in: Plan.Types.keys.map {|k| k.to_s}
  }

  def type
    Plan.Types[self.plan_type.to_sym]
  end
end

