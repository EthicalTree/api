class Plan < ApplicationRecord
  belongs_to :listing

  def self.Types
    {
      # old
      trial: { name: 'Trial', price: 0.00, weight: 100 },
      premium: { name: 'Premium', price: 57.00, weight: 200 },
      bronze: { name: 'Bronze', price: 69.00, weight: 100 },
      silver: { name: 'Silver', price: 129.00, weight: 200 },
      gold: { name: 'Gold', price: 199.00, weight: 400 },

      # new
      basic: { name: 'Basic', price: 119.00, weight: 100 },
      starter: { name: 'Starter', price: 199.00, weight: 200 },
      standard: { name: 'Standard', price: 349.00, weight: 300 },
      enhanced: { name: 'Enhanced', price: 599.00, weight: 400 }
    }
  end

  def self.featured_listings(options={})
    count = options[:count]
    location = options[:location]

    listings = Location.listings

    search_listings = Search.by_location({
      results: listings,
      location: location,
    })

    if search_listings
      listings = search_listings
    end

    listings = listings.joins(
      'JOIN plans ON plans.listing_id = listings.id'
    )

    cases = Plan.Types.map {|k,p| "WHEN plan_type='#{k}' THEN (RAND() * #{p[:weight]})"}

    listings = listings.order(
      "CASE
        #{cases.join("\n")}
        ELSE 100
      END DESC"
    )

    if count.present?
      listings = listings.limit(count)
    end

    listings = listings.map do |l|
      l.listing
    end.shuffle

    listings
  end

  validates :listing_id, presence: true
  validates :plan_type, presence: true, inclusion: {
    in: Plan.Types.keys.map {|k| k.to_s}
  }

  def type
    Plan.Types[self.plan_type.to_sym]
  end
end

