module V1
  class SearchController < APIController

    def search
      page = search_params[:page].to_i
      @query = search_params[:query].downcase
      @ethicalities = search_params[:ethicalities].split(',')

      fields = [
        :id,
        :slug,
        :title,
        :bio,
        build_ethicality_statement,
        build_likeness_statement
      ].compact

      joins = [
        build_ethicality_join,
        :locations
      ].compact

      results = Listing.select(fields).joins(joins).where.not(
        'locations.lat': nil,
        'locations.lng': nil
      ).group(
        'listings.id'
      ).order(
        'eth_total DESC',
        'likeness DESC'
      ).distinct

      results = results.page(page + 1).per(12)

      result_json = {
        listings: results.map{|l| l.as_json_search.merge(eth_total: l.eth_total, likeness: l.likeness) }.as_json,
        currentPage: page,
        pageCount: results.total_pages
      }

      render json: result_json, status: :ok
    end

    private

    def search_params
      params.permit(
        :query,
        :ethicalities,
        :page
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
