module V1
  class ImagesController < APIController
    before_action :require_listing

    def index

    end

    def create
      authorize! :update, @listing
      image = Image.new image_params
      image.order = @listing.images.count + 1
      image.save

      if params[:menu_id]
        @listing.menu.images.push image
        render json: { images: @listing.menu.images.as_json }, status: :ok
      else
        @listing.images.push image
        render json: { images: @listing.images.as_json }, status: :ok
      end

    end

    def show

    end

    def update
      authorize! :update, @listing
      image = @listing.images.find(params[:id])

      make_cover = params[:make_cover]
      offset_y = params[:offset_y] || image.cover_offset_y

      if offset_y != image.cover_offset_y
        image.update(cover_offset_y: offset_y)
      end

      if make_cover
        @listing.images.update_all(order: 1)
        image.update(order: 0)
      end

      render json: { images: @listing.images.as_json }, status: :ok
    end

    def destroy
      authorize! :update, @listing

      if params[:menu_id]
        image = @listing.menu.images.find(params[:id])
        key = image.key
        @listing.menu.images.delete(image)
        images = @listing.menu.images.as_json
      else
        image = @listing.images.find(params[:id])
        key = image.key
        @listing.images.delete(image)
        images = @listing.images.as_json
      end

      s3_image = $fog_images.files.get(key)
      if s3_image
        s3_image.destroy
      end

      s3_thumbnail = $fog_thumbnails.files.get(key)
      if s3_thumbnail
        s3_thumbnail.destroy
      end

      render json: { images: images }, status: :ok
    end

    private

    def image_params
      params.require(:image).permit(
        :key,
      )
    end

    def require_listing
      @listing = Listing.published.find_by!(slug: params[:listing_id])
    end
  end
end
