module V1
  class LocationsController < APIController

    before_action :require_listing

    def index

    end

    def create
      authorize! :update, @listing
      location = Location.new location_params
      @listing.locations = [location]

      render json: { locations: @listing.locations.as_json }, status: :ok
    end

    def show

    end

    def update

    end

    def destroy

    end

    private

    def location_params
      params.require(:location).permit(
        :lat,
        :lng
      )
    end

    def require_listing
      if not @listing = Listing.find_by!(slug: params[:listing_id])
        not_found
      end
    end

  end
end
