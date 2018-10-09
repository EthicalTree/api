module V1
  class SearchController < APIController

    def search
      page = search_params[:page].to_i
      location = search_params[:location]

      swlat = search_params[:swlat]
      swlng = search_params[:swlng]
      nelat = search_params[:nelat]
      nelng = search_params[:nelng]

      if [swlat, swlng, nelat, nelng].all? {|p| p.present?}
        location = {
          swlat: swlat.to_f,
          swlng: swlng.to_f,
          nelat: nelat.to_f,
          nelng: nelng.to_f,
        }
      end

      @query = search_params[:query].strip.downcase
      @ethicalities = search_params[:ethicalities].split(',')
      @open_now = JSON.parse(search_params[:open_now])

      @regex_query = build_regex_query(@query)

      fields = [
        :id,
        :lat,
        :lng,
        'listing_id',
        'listings.id',
        'listings.slug',
        'listings.title',
        'listings.bio',
        build_hashtag_statement,
        build_ethicality_statement,
        build_likeness_statement
      ].compact

      joins = [
        'LEFT JOIN operating_hours ON operating_hours.listing_id = locations.listing_id',
        "LEFT JOIN plans ON plans.listing_id = locations.listing_id",
        build_tag_join,
        build_ethicality_join,
      ].compact

      results = Location.listings.select(fields).joins(joins).where.not(
        'locations.lat': nil,
        'locations.lng': nil,
        'locations.listing_id': nil
      ).group(
        'locations.id',
        'listings.id',
      ).distinct(
        'listings.id'
      ).order(
        'eth_total DESC',
        'likeness DESC',
        'hashtag_count DESC',
        'isnull(plans.listing_id) ASC'
      )

      located_results = Search::by_location({
        results: results,
        location: location,
      })

      if located_results
        located = true

        results = located_results

        results_that_match = results.having(
          "eth_total > 0 AND (likeness > 0 OR hashtag_count > 0)"
        )

        if @open_now
          results_that_match = filter_open_now(results_that_match)
        end
      else
        located = false
        results_that_match = []
      end

      if results_that_match.length > 0
        results = results_that_match
      end

      results = results.page(page).per(12)

      result_json = {
        listings: results.map{|l| l.listing.as_json_search},
        located: located,
        current_page: page,
        matches: results_that_match.length,
        page_count: results.total_pages
      }

      render json: result_json, status: :ok
    end

    private

    def search_params
      params.permit(
        :query,
        :ethicalities,
        :open_now,
        :page,
        :location,
        :swlat,
        :swlng,
        :nelat,
        :nelng
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

    def build_tag_join
      if @query.present? and @regex_query.present?
        query = Listing.connection.quote(@regex_query)

        "LEFT JOIN listing_tags ON listing_tags.listing_id = listings.id
         LEFT JOIN tags ON tags.id = listing_tags.tag_id AND
          tags.hashtag RLIKE #{query}
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
      if @query.present? and @regex_query.present?
        query = Listing.connection.quote(@regex_query)

        "CASE
          WHEN (
            LOWER(listings.title) RLIKE #{query} OR
            LOWER(listings.bio) RLIKE #{query}
          ) AND plans.listing_id IS NOT NULL THEN 4
          WHEN LOWER(listings.title) RLIKE #{query} THEN 3
          WHEN LOWER(listings.bio) RLIKE #{query} THEN 2
          ELSE 0
        END as 'likeness'"
      else
        "1 as 'likeness'"
      end
    end

    def build_hashtag_statement
      if @query.present?
        'COUNT(tags.hashtag) AS hashtag_count'
      else
        '1 as hashtag_count'
      end
    end

    def filter_open_now(collection)
      # make sure the collection has a join of "operating_hours"
      # TODO replace America/New_York with a solution for multiple timezones
      # once we have cities outside the eastern timezone
      collection.where(
        "operating_hours.day = :today AND
            operating_hours.open_time <= :now AND
            operating_hours.close_time > :now",
        today: Timezone.now('America/New_York').strftime('%A').downcase,
        now: Timezone.now('America/New_York')
      )
    end

    def build_regex_query(query)
      "(#{query.tr(' ', '|')})"
    end
  end
end
