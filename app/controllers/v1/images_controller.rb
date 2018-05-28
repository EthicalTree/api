module V1
  class ImagesController < APIController
    def index

    end

    def create
      authorize_for_type :update, params[:type]

      image = Image.new image_params
      image.order = @images.count + 1
      image.save
      @images.push image

      render(json: {
        images: @images.reload
      }, status: :ok)
    end

    def show

    end

    def update
      type = params[:type]
      authorize_for_type :update, type
      image = @images.find(params[:id])

      if type == 'listing'
        offset_y = params[:offset_y] || image.cover_offset_y

        if offset_y != image.cover_offset_y
          image.update(cover_offset_y: offset_y)
        end
      end

      if params[:make_cover]
        @images.update_all(order: 1)
        image.update(order: 0)
      end

      render json: { images: @images.reload }, status: :ok
    end

    def destroy
      authorize_for_type :update, params[:type]
      image = @images.find_by(id: params[:id])

      key = image.key
      @images.delete(image)

      s3_image = $fog_images.files.get(key)
      if s3_image
        s3_image.destroy
      end

      s3_thumbnail = $fog_thumbnails.files.get(key)
      if s3_thumbnail
        s3_thumbnail.destroy
      end

      render json: { images: @images.reload }, status: :ok
    end

    private

    def authorize_for_type auth, type
      if type == 'listing'
        require_listing
        authorize! auth, @listing
        @images = @listing.images
      elsif type == 'menu'
        require_listing
        authorize! auth, @listing
        @images = @listing.menu.images
      elsif type == 'collection'
        require_collection
        authorize! auth, Collection
        @images = @collection.images
      else
        raise 'Unsupported image type'
      end
    end

    def image_params
      params.require(:image).permit(
        :key,
      )
    end

    def require_listing
      @listing = Listing.published.find_by!(slug: params[:listing_id])
    end

    def require_collection
      @collection = Collection.find_by!(slug: params[:collection_id])
    end
  end
end
