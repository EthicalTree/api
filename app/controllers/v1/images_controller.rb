module V1
  class ImagesController < APIController
    before_action :require_listing
    before_action :has_permission

    def index

    end

    def create
      image = Image.new image_params
      @listing.images.push image

      render json: { images: @listing.images.as_json.rotate(-1) }, status: :ok
    end

    def show

    end

    def update
      image = @listing.images.find(params[:id])
      make_cover = params[:make_cover]

      if make_cover
        @listing.images.update_all(order: 0)
        image.update(order: 1)

        render json: { images: @listing.images.as_json }, status: :ok
      end
    end

    def destroy
      image = @listing.images.find(params[:id])

      image.destroy
      render json: { images: @listing.images.as_json }, status: :ok
    end

    private

    def image_params
      params.require(:image).permit(
        :key,
      )
    end

    def require_listing
      if not @listing = Listing.find_by!(slug: params[:listing_id])
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
