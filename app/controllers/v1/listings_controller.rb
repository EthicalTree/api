module V1
  class ListingsController < APIController
    before_action :require_listing, only: %i{show update destroy}
    before_action :authenticate_user, only: %i{update}

    def index

    end

    def create
      @listing = Listing.new listing_params

      if @listing.save
        render json: { slug: @listing.slug }, status: :ok
      else
        render json: { errors: @listing.errors.full_messages }
      end
    end

    def show
      json_response @listing.as_json include: [:ethicalities, :images, :locations]
    end

    def update
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
        :bio,
      )
    end

    def require_listing
      @listing = Listing.find_by(slug: params[:id])
    end

  end
end
