module V1
  class LocationsController < APIController

    before_action :require_listing

    def index

    end

    def create
      authorize! :update, @listing

      if params[:location].present?
        location = Location.new location_params

        DirectoryLocation.create_locations location.lat, location.lng
        location.determine_location_details

        if location.city.present?
          directory_location, _ = Search.find_directory_location(
            location.city,
            is_city_scope: true
          )

          @listing.directory_location = directory_location
        end

        @listing.locations = [location]
        @listing.save

        render json: { locations: @listing.locations.as_json }, status: :ok
      else
        render json: { errors: ['You must specify a location for your listing'], status: :ok }
      end
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
      @listing = Listing.published.find_by!(slug: params[:listing_id])
    end

  end
end
