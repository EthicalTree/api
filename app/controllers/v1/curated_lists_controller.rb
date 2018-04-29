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

          json[:listings] = cl._listings({
            location: location
          }).map {|l| l.listing.as_json_search}

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

      listings = Location.listings.joins(
        "INNER JOIN listing_tags ON listings.id = listing_tags.listing_id"
      ).where(
        'listing_tags.tag_id': list.tag.id
      )

      listings = Search.by_location(listings, location)
      listings = listings.order(
        'distance DESC'
      ).distinct.page(page).per(18)

      render json: {
        name: list.name,
        slug: list.slug,
        listings: listings.map {|l| l.listing.as_json_search},
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
