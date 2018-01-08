module V1
  class ListingEthicalitiesController < APIController

    before_action :require_listing
    before_action :authenticate_user, only: %i{update create destroy}

    def index
      render json: { ethicalities: @listing.ethicalities.as_json }, status: 200
    end

    def create
      authorize! :update, @listing
      @listing.ethicalities = []
      ethicality_params[:ethicalities].each do |e|
        ethicality = Ethicality.find_by slug: e[:slug]
        @listing.ethicalities.push ethicality
      end
      render json: { ethicalities: @listing.ethicalities.as_json }, status: 200
    end

    def show

    end

    def update

    end

    def destroy

    end

    private

    def ethicality_params
      params.permit(ethicalities: [:slug])
    end

    def require_listing
      @listing = Listing.published.find_by!(slug: params[:listing_id])
    end

  end

end
