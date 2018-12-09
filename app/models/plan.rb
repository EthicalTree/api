# frozen_string_literal: true

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
      basic: { name: 'Basic', price: 119.00, weight: 125 },
      starter: { name: 'Starter', price: 199.00, weight: 250 },
      standard: { name: 'Standard', price: 349.00, weight: 500 },
      enhanced: { name: 'Enhanced', price: 599.00, weight: 1000 }
    }
  end

  def self.featured_listings(options = {})
    count = options[:count]
    is_city_scope = options[:is_city_scope]
    location = options[:location]

    all_listings = Location.includes(
      listing: %i[
        ethicalities
        locations
        operating_hours
        plan
      ]
    ).listings

    search_listings = Search.by_location(
      is_city_scope: is_city_scope,
      results: all_listings,
      location: location
    )

    search_listings = search_listings.joins(
      'JOIN plans ON plans.listing_id = listings.id'
    )

    if search_listings.length >= count.to_i
      # if there are enough featured listings withing the city already
      # then order them by weight
      listings = search_listings

      cases = Plan.Types.map { |k, p| "WHEN plan_type='#{k}' THEN (RAND() * #{p[:weight]})" }

      listings = listings.order(
        "CASE
          #{cases.join("\n")}
          ELSE 100
        END DESC"
      )

      listings = listings.limit(count) if count.present?

      listings = listings.shuffle

    else
      # if there aren't enough featured listings within the city
      # yet, then just find the closest ones on a plan
      directory_location, = Search::find_directory_location(location, {
        is_city_scope: is_city_scope
      })

      coords = [directory_location['lat'], directory_location['lng']]

      listings = all_listings.joins(
        'JOIN plans ON plans.listing_id = listings.id'
      )

      listings = listings.within(
        200,
        units: :kms,
        origin: coords
      ).reorder('distance ASC')

      listings = listings.limit(count) if count.present?

    end

    listings.map(&:listing)
  end

  validates :listing_id, presence: true
  validates :plan_type, presence: true, inclusion: {
    in: Plan.Types.keys.map(&:to_s)
  }

  def type
    Plan.Types[plan_type.to_sym]
  end
end
