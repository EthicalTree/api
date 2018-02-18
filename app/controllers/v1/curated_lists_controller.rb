module V1
  class CuratedListsController < APIController
    def index
      location = "front_page"
      results = CuratedList.where({
        location: location,
        hidden: false
      })

      render json: { curated_lists: results.as_json(
        include: {
          tag: {
            methods: :sampled_listings
          }
        }
      )}
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
