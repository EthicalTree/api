module V1
  module Admin
    class ListingsController < APIController

      before_action :authenticate_user

      def index
        authorize! :read, Listing

        page = params[:page].to_i or 1
        results = Listing.all.page(page).per(25)
        render json: {
          listings: results.as_json,
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
        @listing.assign_attributes listing_params

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
        )
      end
    end
  end
end
