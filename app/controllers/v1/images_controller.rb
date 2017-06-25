module V1
  class ImagesController < APIController
    before_action :require_listing

    def index

    end

    def create
      image = Image.new image_params
      @listing.images.push image

      render json: { images: @listing.images.as_json }, status: :ok
    end

    def show

    end

    def update

    end

    def destroy

    end

    private

    def image_params
      params.require(:image).permit(
        :key,
      )
    end

    def require_listing
      @listing = Listing.find_by!(slug: params[:listing_id])
    end

  end
end
