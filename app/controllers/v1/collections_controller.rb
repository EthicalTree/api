module V1
  class CollectionsController < APIController
    def index
      location_id = params[:location]
      page = params[:page] || 1
      where = params[:where] || ''

      results = Collection.where({ hidden: false }).order(:order)

      if location_id.present?
        directory_location, _ = Search.find_directory_location(
          location_id,
          is_city_scope: true
        )

        results = results.joins([
          'INNER JOIN listing_tags ON listing_tags.tag_id = collections.tag_id',
          "INNER JOIN listings ON (
            listing_tags.listing_id = listings.id AND
            listings.directory_location_id = #{directory_location.id}
          )",
        ])
      end

      if where.present?
        results = results.where({ location: where })
      end

      results = results.distinct.page(page).per(12)

      render json: {
        current_page: page,
        total_pages: results.total_pages,
        collections: results.map do |cl|
          json = cl.as_json(
            only: [ :name, :id, :slug ],
            include: {tag: { only: :hashtag }}
          )

          if cl.featured
            json[:listings] = Plan.featured_listings({
              count: 6,
              location: location_id,
              is_city_scope: true
            }).map {|l| l.as_json_search}
          else
            json[:listings] = cl._listings({
              location: location_id,
              is_city_scope: true
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
      collection = Collection.find_by(slug: params[:id])

      if !collection.present?
        return json_response({ message: 'Collection not found' }, :not_found)
      end

      if collection.featured
        listings = Location.listings.joins(
          'JOIN plans ON plans.listing_id = listings.id'
        ).where(
          'plans.listing_id IS NOT NULL'
        )
      else
        listings = Location.listings.joins(
          "INNER JOIN listing_tags ON listings.id = listing_tags.listing_id"
        ).where(
          'listing_tags.tag_id': collection.tag.id
        )
      end

      search_listings = Search::by_location({
        is_city_scope: true,
        location: location,
        radius: 50,
        results: listings,
      })

      if search_listings
        listings = search_listings
      end

      listings = listings.distinct.page(page).per(24)

      render json: {
        name: collection.name,
        description: collection.description,
        slug: collection.slug,
        cover_image: collection.cover_image,
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
