# frozen_string_literal: true

module V1
  class DirectoryLocationsController < APIController
    def include_neighbourhoods(location)
      # pass in location hash to populate it with neighbourhoods
      city = location['city']
      results = DirectoryLocation.get_neighborhoods_for_city(city)
      city_id = DirectoryLocation.find_by(city: city, location_type: 'city').id
      city_listings = Location.listings.where(
        'directory_location_id = ?',
        city_id
      )

      location['neighbourhoods'] = results.map do |loc|
        {
          id: loc.id,
          name: loc.name,
          listings_count: Search.by_location(
            results: city_listings,
            location: loc.name
          ).count
        }
      end

      location
    end

    def index
      query = params[:query]
      name = params[:name]
      with_neighbourhoods = params[:withNeighbourhoods].present?

      if name == 'Near Me'
        location = ip_location_information
        render json: location, status: :ok
      elsif name.present?
        location, = Search.find_directory_location(name)
        location = location.as_json
        location = include_neighbourhoods(location) if with_neighbourhoods
        render json: location, status: :ok
      else
        results = DirectoryLocation.select(:name, :city, :id)

        results = results.where(
          'name LIKE :query',
          query: "%#{query}%"
        ).order(
          "CASE
            WHEN name LIKE #{Listing.connection.quote("#{query}%")} THEN 1
            WHEN name LIKE #{Listing.connection.quote("%#{query}%")} THEN 3
            ELSE 2
          END, name"
        )

        results = results.limit(6)
        render json: results.as_json, status: :ok
      end
    end

    def create; end

    def show
      id = params[:id]
      with_neighbourhoods = params[:withNeighbourhoods].present?

      location = DirectoryLocation.find(id).as_json
      location = include_neighbourhoods(location) if with_neighbourhoods

      render json: location, status: :ok
    end

    def update; end

    def destroy; end
  end
end
