module V1
  class CuratedListsController < APIController
    def index
      results = CuratedList.where({
        hidden: false
      }).order(:order)

      render json: {
        curated_lists: results.as_json(
          include: {
            tag: {
              methods: :sampled_listings
            }
          }
        )
      }
    end

    def create
    end

    def show
    end

    def update
    end

    def destroy
    end

  end
end
