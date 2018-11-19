module V1
  class ImagesController < APIController
    def index
    end

    def create
      authorize_for_type :update, params[:type]

      image = Image.new image_params
      image.order = @source.images.count + 1
      image.save
      @source.images.push image
      @source.rebuild_image_order

      render(json: {
        images: @source.images.reload
      }, status: :ok)
    end

    def show
    end

    def update
      type = params[:type]
      shift = params[:shift]
      authorize_for_type :update, type
      @source.rebuild_image_order

      image = @source.images.find(params[:id])

      if type == 'listing'
        offset_y = params[:offset_y] || image.cover_offset_y

        if offset_y != image.cover_offset_y
          image.update(cover_offset_y: offset_y)
        end
      end

      if params[:make_cover]
        @source.make_cover_image image
      end

      if shift && ['previous', 'next'].include?(shift)
        @source.shift_image image, shift
      end

      render json: { images: @source.images.reload }, status: :ok
    end

    def destroy
      authorize_for_type :update, params[:type]
      image = @source.images.find_by(id: params[:id])

      key = image.key
      @source.images.delete(image)

      s3_image = $fog_ethicaltree.files.get(key)
      if s3_image
        s3_image.destroy
      end

      s3_thumbnail = $fog_thumbnails.files.get(key)
      if s3_thumbnail
        s3_thumbnail.destroy
      end

      @source.rebuild_image_order

      render json: { images: @source.images.reload }, status: :ok
    end

    private

    def authorize_for_type auth, type
      if type == 'listing'
        require_listing
        authorize! auth, @listing
        @source = @listing
      elsif type == 'menu'
        require_listing
        authorize! auth, @listing
        @source = @listing.menu
      elsif type == 'collection'
        require_collection
        authorize! auth, Collection
        @source = @collection
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
