module V1
  class SearchController < APIController

    def search
      page = search_params[:page].to_i
      location = search_params[:location]
      @query = search_params[:query].downcase
      @ethicalities = search_params[:ethicalities].split(',')

      featured = Plan.featured_listings

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
        "LEFT JOIN plans ON plans.id = locations.listing_id",
        build_ethicality_join,
      ].compact

      results = Location.listings.select(fields).joins(joins).where.not(
        'locations.lat': nil,
        'locations.lng': nil,
        listing_id: featured.map {|l| l.id}
      ).group(
        'locations.id',
        'listings.id'
      )

      results = Search.by_location({
        results: results,
        location: location,
        filtered: true
      })

      results = results.order(
        'eth_total DESC',
        'likeness DESC',
        'distance DESC'
      ).distinct()

      results_that_match = results.having(
        "eth_total > 0 AND likeness > 0"
      )

      if results_that_match.length > 0
        results = results_that_match
      else
        results = results.order('RAND()').limit(12)
      end

      results = results.page(page).per(12)
      result_ids = results.map {|r| r.id}
      listings = Listing.find(result_ids).index_by(&:id).slice(*result_ids).values

      result_json = {
        featured: featured.map{|l| l.as_json_search},
        listings: listings.map{|l| l.as_json_search},
        current_page: page,
        matches: results_that_match.length,
        page_count: results.total_pages
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
        "COUNT(ethicalities.slug) as 'eth_total'"
      else
        "1 as 'eth_total'"
      end
    end

    def build_likeness_statement
      if @query.present?
        query = Listing.connection.quote("%#{@query}%")

        "CASE
          WHEN (
            LOWER(listings.title) LIKE #{query} OR
            LOWER(listings.bio) LIKE #{query}
          ) AND plans.id IS NOT NULL THEN 3
          WHEN LOWER(listings.title) LIKE #{query} THEN 2
          WHEN LOWER(listings.bio) LIKE #{query} THEN 1
          ELSE 0
        END as 'likeness'"
      else
        "1 as 'likeness'"
      end
    end

  end
end
