module V1
  class SearchController < APIController

    def search
      page = search_params[:page].to_i
      location = search_params[:location]
      @query = search_params[:query].downcase
      @ethicalities = search_params[:ethicalities].split(',')

      fields = [
        :id,
        :lat,
        :lng,
        'listings.id',
        'listings.slug',
        'listings.title',
        'listings.bio',
        build_ethicality_statement,
        build_likeness_statement
      ].compact

      joins = [
        "INNER JOIN listings ON listings.id = locations.listing_id AND listings.visibility = 0",
        build_ethicality_join,
      ].compact

      results = Location.select(fields).joins(joins).where.not(
        'locations.lat': nil,
        'locations.lng': nil
      ).group(
        'locations.id',
        'listings.id'
      )

      if location.present?
        directory_location = DirectoryLocation.find_by(name: location)

        if directory_location.present?
          results = results.in_bounds(directory_location.bounds, origin: directory_location.coordinates)
        else
          location = MapApi.build_from_address(location)[:location]
          coords = [location['lat'], location['lng']]
          results = results.within(10, units: :kms, origin: coords)
        end

      else
        coords = [location_information[:latitude], location_information[:longitude]]
        results = results.within(10, units: :kms, origin: coords)
      end

      results = results.order(
        'eth_total DESC',
        'likeness DESC'
      )

      results = results.distinct().page(page + 1).per(12)
      result_ids = results.map {|r| r.id}
      listings = Listing.find(result_ids).index_by(&:id).slice(*result_ids).values

      result_json = {
        listings: listings.map{|l| l.as_json_search location: location_information},
        currentPage: page,
        pageCount: results.total_pages
      }

      render json: result_json, status: :ok
    end

    def locations
      latlng = [location_information[:latitude], location_information[:longitude]]
      query = params[:query]

      results = DirectoryLocation.select(:name)

      if query.present?
        results = results.where(
          "name LIKE :query",
          query: "%#{query}%"
        ).order(
          "CASE
            WHEN name LIKE #{Listing.connection.quote("#{query}%")} THEN 1
            WHEN name LIKE #{Listing.connection.quote("%#{query}%")} THEN 3
            ELSE 2
          END, name"
        )
      end

      results = results.by_distance(origin: latlng).limit(6)

      render json: results.map {|r| r.name}, status: :ok
    end

    def suggestions
      query = params[:query]

      ethicalities = Ethicality.where(
        "name LIKE :query",
        query: "%#{query}%"
      )

      results = [{
        title: 'Ethical Preference',
        suggestions: ethicalities.map {|e| e.as_json.merge({ type: 'ethicality' })}
      }]

      render json: results, status: :ok
    end

    private

    def search_params
      params.permit(
        :query,
        :ethicalities,
        :page,
        :location
      )
    end

    def build_ethicality_join
      ethicalities = @ethicalities.map do |e|
        e = Ethicality.connection.quote(e)
      end.join(',')

      if @ethicalities.present?
        "INNER JOIN listing_ethicalities ON listing_ethicalities.listing_id = listings.id
         INNER JOIN ethicalities
          ON listing_ethicalities.ethicality_id = ethicalities.id
          AND ethicalities.slug IN (#{ethicalities})
        "
      end
    end

    def build_ethicality_statement
      if @ethicalities.present?
        'COUNT(ethicalities.slug) as eth_total'
      else
        '0 as eth_total'
      end
    end

    def build_likeness_statement
      if @query.present?
        query = @query

        "(
          SELECT COUNT(likeness_listings.id) FROM listings likeness_listings
          WHERE likeness_listings.id = listings.id AND
          LOWER(listings.title) LIKE #{Listing.connection.quote("%#{query}%")}
        ) AS likeness"
      else
        "0 as likeness"
      end
    end

  end
end
