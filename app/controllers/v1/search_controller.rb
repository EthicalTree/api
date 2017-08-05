module V1
  class SearchController < APIController

    def search
      results = Listing.page(1).per(12)
      result_json = results.map{|l| l.as_json_search }.as_json

      render json: result_json, status: :ok
    end

    private

    def search_params
      params.require(:search).permit(
        :query,
        :ethicalities
      )
    end



  end
end
