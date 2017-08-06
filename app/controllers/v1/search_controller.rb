module V1
  class SearchController < APIController

    def search
      page = search_params[:page].to_i
      results = Listing.page(page + 1).per(12)

      result_json = {
        listings: results.map{|l| l.as_json_search }.as_json,
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
