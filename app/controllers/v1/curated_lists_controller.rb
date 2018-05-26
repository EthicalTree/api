module V1
  class CuratedListsController < APIController
    def index
      location = params[:location]

      results = CuratedList.where({
        hidden: false
      }).order(:order)

      render json: {
        curated_lists: results.map do |cl|
          json = cl.as_json(
            only: [ :name, :id, :slug ],
            include: {tag: { only: :hashtag }}
          )

          if cl.featured
            json[:listings] = Plan.featured_listings({
              count: 6,
              location: location
            }).map {|l| l.as_json_search}
          else
            json[:listings] = cl._listings({
              location: location
            }).map {|l| l.listing.as_json_search}
          end

          json
        end
      }
    end

    def create
    end

    def show
      location = params[:location]
      page = params[:page] || 1
      list = CuratedList.find_by(slug: params[:id])

      if !list.present?
        return json_response({ message: 'Collection not found' }, :not_found)
      end

      if list.featured
        listings = Location.listings.joins(
          'JOIN plans ON plans.listing_id = listings.id'
        ).where(
          'plans.listing_id IS NOT NULL'
        )
      else
        listings = Location.listings.joins(
          "INNER JOIN listing_tags ON listings.id = listing_tags.listing_id"
        ).where(
          'listing_tags.tag_id': list.tag.id
        )
      end

      listings = Search.by_location({
        results: listings,
        location: location,
        filtered: true,
        radius: 50
      }).order(
        'distance DESC'
      ).distinct.page(page).per(18)

      render json: {
        name: list.name,
        slug: list.slug,
        listings: listings.map {|l| l.listing.as_json_search},
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
