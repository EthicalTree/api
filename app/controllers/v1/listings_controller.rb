module V1
  class ListingsController < APIController
    before_action :require_listing, only: %i{show update destroy}
    before_action :authenticate_user, only: %i{update create destroy}
    before_action :has_permission, only: %i{update create destroy}

    def index

    end

    def create
      authorize! :create, Listing
      @listing = Listing.new listing_params
      @listing.owner_id = current_user.id

      if @listing.save
        json_response @listing.as_json_full
      else
        render json: { errors: @listing.errors.full_messages }
      end
    end

    def show
      json_response @listing.as_json_full
    end

    def update
      authorize! :update, @listing
      @listing.assign_attributes listing_params

      if @listing.save
        render json: { listing: @listing.as_json }, status: :ok
      else
        render json: { errors: @listing.errors.full_messages }
      end
    end

    def destroy

    end

    private

    def listing_params
      params.require(:listing).permit(
        :title,
        :bio
      )
    end

    def require_listing
      if not @listing = Listing.find_by(slug: params[:id])
        not_found
      end
    end

    def has_permission
      if not current_user.can_edit_listing
        not_found
      end
    end

  end
end
