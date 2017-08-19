module V1
  class SearchController < APIController

    def search
      query = search_params[:query].split(' ')
      page = search_params[:page].to_i
      ethicalities = search_params[:ethicalities].split(',')

      results = Listing.includes([:locations, :ethicalities])

      if ethicalities.any?
        results = results.where(
          ethicalities: { slug: ethicalities }
        )
      end

      if query.any?
        inner_search = nil

        Listing.search_fields.each do |field|
          inner_query = results.where("LOWER(#{field}) LIKE ?", "%#{query[0].downcase}%")
          if inner_search
            inner_search = inner_search.or(inner_query)
          else
            inner_search = inner_query
          end
        end

        results = inner_search
      end

      results = results.where.not(
        locations: { listing_id: nil }
      ).page(page + 1).per(12)

      result_json = {
        listings: results.map{|l| l.reload and l.as_json_search }.as_json,
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

  end
end
