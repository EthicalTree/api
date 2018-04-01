module V1
  class TagsController < APIController
    def index

    end

    def create
    end

    def show
      page = params[:page] || 1
      tag = Tag.find_by({hashtag: params[:id]})
      listings = tag.listings.page(page).per(18)

      render json: {
        hashtag: tag.hashtag,
        listings: listings.map {|l| l.as_json_search},
        current_page: page,
        total_pages: listings.total_pages
      }
    end

    def update
    end

    def destroy
    end

  end
end
