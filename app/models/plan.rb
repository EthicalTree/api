class Plan < ApplicationRecord
  belongs_to :listing

  def self.Types
    {
      trial: { name: 'Trial', price: 0.00, weight: 100 },
      premium: { name: 'Premium', price: 57.00, weight: 200 },
      bronze: { name: 'Bronze', price: 69.00, weight: 100 },
      silver: { name: 'Silver', price: 129.00, weight: 200 },
      gold: { name: 'Gold', price: 189.00, weight: 400 }
    }
  end

  def self.featured_listings(options={})
    count = options[:count] || 4
    location = options[:location]

    listings = Location.listings
    listings = Search.by_location({
      results: listings,
      location: location,
      by_radius: true,
      filtered: true
    }).joins('JOIN plans ON plans.listing_id = listings.id')

    cases = Plan.Types.map {|k,p| "WHEN plan_type='#{k}' THEN (RAND() * #{p[:weight]})"}

    listings.order(
      "CASE
        #{cases.join("\n")}
        ELSE 100
      END DESC"
    ).limit(count).map do |l|
      l.listing
    end.shuffle
  end

  validates :listing_id, presence: true
  validates :plan_type, presence: true, inclusion: {
    in: Plan.Types.keys.map {|k| k.to_s}
  }

  def type
    Plan.Types[self.plan_type.to_sym]
  end
end

