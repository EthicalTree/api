module V1
  class ListingsController < APIController

    before_action :require_listing, only: %i{show update destroy}

    def index

    end

    def create

    end

    def show
      json_response @listing
    end

    def update

    end

    def destroy

    end

    private

    def listing_params

    end

    def require_listing
      @listing = Listing.find(params[:id])
    end

  end
end
