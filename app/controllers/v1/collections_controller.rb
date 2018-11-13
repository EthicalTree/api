module V1
  class CollectionsController < APIController
    def index
      location_join = ""

      location_id = params[:location]
      page = params[:page] || 1
      where = params[:where] || ''

      results = Collection.where({ hidden: false }).order(:order)

      if location_id.present?
        directory_location, _ = Search.find_directory_location(
          location_id,
          is_city_scope: true
        )

        location_join = "AND listings.directory_location_id = #{directory_location.id}"
      end

      # Filter for collections that actually have listings assigned
      results = results.joins([
                                'INNER JOIN listing_tags ON listing_tags.tag_id = collections.tag_id',
                                "INNER JOIN listings ON listing_tags.listing_id = listings.id #{location_join}",
                              ])

      if where.present?
        results = results.where({ location: where })
      end

      results = results.distinct.page(page).per(12)

      render json: {
        current_page: page,
        total_pages: results.total_pages,
        collections: results.map do |cl|
          json = cl.as_json(
            only: [:name, :id, :slug],
            include: { tag: { only: :hashtag } }
          )

          if cl.featured
            json[:listings] = Plan.featured_listings({
                                                       count: 6,
                                                       location: location_id,
                                                       is_city_scope: true
                                                     }).map { |l| l.as_json_search }
          else
            json[:listings] = cl._listings({
                                             location: location_id,
                                             is_city_scope: true
                                           }).map { |l| l.listing.as_json_search }
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
        joins = ['INNER JOIN plans p ON p.listing_id = listings.id']
      else
        joins = ["
          INNER JOIN
            listing_tags ON listings.id = listing_tags.listing_id AND
            listing_tags.tag_id = #{collection.tag.id}
          LEFT JOIN plans p ON p.listing_id = listings.id
        "]
      end

      listings = Location.listings.joins(joins)

      search_listings = Search::by_location({
                                              is_city_scope: true,
                                              location: location,
                                              radius: 50,
                                              results: listings,
                                            })

      if search_listings
        listings = search_listings
      end

      listings = listings.group(
        :id,
        :listing_id
      ).order(
        'isnull(p.listing_id) ASC',
      ).page(
        page
      ).per(24)

      listings.each { |l| puts l.listing_id }

      render json: {
        name: collection.name,
        description: collection.description,
        slug: collection.slug,
        cover_image: collection.cover_image,
        listings: listings.map { |l| l.listing.as_json_search },
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
