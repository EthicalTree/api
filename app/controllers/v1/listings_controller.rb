module V1
  class ListingsController < APIController
    before_action :require_listing, only: %i{show update destroy}
    before_action :authenticate_user, only: %i{update create destroy}

    def index
      count = params[:count]
      location = params[:location]
      is_featured = params[:is_featured]

      if is_featured
        listings = Plan.featured_listings({
          count: count,
          location: location,
          location_information: location_information
        })

        render json: {
          listings: listings.map {|l| l.as_json_search},
        }
      else

      end
    end

    def create
      authorize! :create, Listing
      @listing = Listing.new listing_params
      @listing.owner_id = current_user.id

      if @listing.save
        ListingMailer.listing_created(@listing).deliver_later
        json_with_permissions @listing, :as_json_full
      else
        render json: { errors: @listing.errors.full_messages }
      end
    end

    def show
      json_with_permissions @listing, :as_json_full
    end

    def update
      claim = listing_params[:claim]
      claim_id = listing_params[:claim_id]

      if claim == true
        if ['pending_verification', 'claimed'].include? @listing.claim_status
          @listing.errors.add(:base, 'Sorry, this listing has already been claimed.')
        else
          @listing.owner = current_user

          if claim_id == @listing.claim_id
            @listing.claim_status = :claimed
          else
            @listing.claim_status = :pending_verification
          end
        end
      else
        authorize! :update, @listing
        @listing.assign_attributes listing_params
      end

      if @listing.save
        if claim == true
          AccountMailer.listing_claimed(current_user, @listing).deliver_later
          render json: { claimed: true }
        else
          json_with_permissions @listing, :as_json
        end
      else
        render json: { errors: @listing.errors.full_messages }
      end
    end

    def destroy

    end

    private

    def listing_params
      params.require(:listing).permit(
        :claim,
        :claim_id,
        :title,
        :phone,
        :bio,
        :visibility,
        :website
      )
    end

    def require_listing
      @listing = Listing.published.find_by!(slug: params[:id])
    end
  end
end
