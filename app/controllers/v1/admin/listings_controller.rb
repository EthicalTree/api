module V1
  module Admin
    class ListingsController < APIController

      before_action :authenticate_user

      def index
        authorize! :read, Listing

        page = params[:page].to_i or 1
        results = Listing.all.page(page).per(25)
        render json: {
          listings: results.map {|l| l.as_json_admin},
          current_page: page,
          total_pages: results.total_pages
        }
      end

      def create

      end

      def show

      end

      def update
        authorize! :update, Listing

        @listing = Listing.find params[:id]
        @listing.assign_attributes({
          visibility: listing_params[:visibility]
        })

        if listing_params[:plan_type].present?
          price = BigDecimal(listing_params[:price])

          plan = Plan.find_or_create_by listing_id: @listing.id
          plan.assign_attributes({
            listing_id: @listing.id,
            plan_type: listing_params[:plan_type],
            price: price
          })

          plan.save
        else
          @listing.plan.delete
        end

        if @listing.save
          render json: {}
        else
          render json: { errors: @listing.errors.full_messages }
        end
      end

      def destroy

      end

      private

      def listing_params
        params.require(:listing).permit(
          :visibility,
          :plan_type,
          :price,
          :id
        )
      end
    end
  end
end
