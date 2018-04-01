module V1
  class CuratedListsController < APIController
    def index
      results = CuratedList.where({
        hidden: false
      }).order(:order)

      render json: {
        curated_lists: results.as_json(
          only: [ :name, :id ],
          include: {tag: { only: :hashtag }},
          methods: :listings
        )
      }
    end

    def create
    end

    def show
      page = params[:page] || 1
      tag = Tag.find_by({hashtag: params[:id]})
      list = CuratedList.find_by(tag: tag)
      listings = tag.listings.page(page).per(18)

      render json: {
        name: list.name,
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
