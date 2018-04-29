module V1
  class CuratedListsController < APIController
    def index
      results = CuratedList.where({
        hidden: false
      }).order(:order)

      render json: {
        curated_lists: results.as_json(
          only: [ :name, :id, :slug ],
          include: {tag: { only: :hashtag }},
          methods: :listings
        )
      }
    end

    def create
    end

    def show
      page = params[:page] || 1
      list = CuratedList.find_by(slug: params[:id])
      listings = list.tag.listings.page(page).per(18)

      render json: {
        name: list.name,
        slug: list.slug,
        listings: listings.map {|l| l.as_json_search},
        current_page: page,
        featured_listings: Plan.featured_listings.map{|l| l.as_json_search},
        total_pages: listings.total_pages
      }
    end

    def update
    end

    def destroy
    end

  end
end
