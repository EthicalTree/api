module V1
  class ListingTagsController < APIController
    before_action :require_listing, only: %i{create update destroy}
    before_action :authenticate_user, only: %i{create update destroy}

    def index
    end

    def create
      authorize! :update, @listing
      hashtag = Tag.strip_hashes(tag_params[:hashtag])
      tag = Tag.find_or_create_by hashtag: hashtag

      if !@listing.tags.find_by(hashtag: hashtag).present?
        @listing.tags.push(tag)
        @listing.save
        render json: { tag: tag }, status: :ok
      else
        render json: { }, status: :conflict
      end

    end

    def show

    end

    def update

    end

    def destroy
      authorize! :update, @listing
      tag = Tag.find_by id: params[:id]
      if tag.present?
        @listing.tags = @listing.tags.reject {|t| t.id == tag.id}
        @listing.save
        render json: { tag: tag }, status: :ok
      else
        render json: { }, status: :notfound
      end
    end

    private

    def tag_params
      params.require(:tag).permit([
        :hashtag,
        :use_type
      ])
    end

    def require_listing
      @listing = Listing.published.find_by!(slug: params[:listing_id])
    end

  end

end
