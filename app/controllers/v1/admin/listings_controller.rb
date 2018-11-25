module V1
  module Admin
    class ListingsController < APIController
      before_action :authenticate_user

      def index
        authorize! :read, Listing

        query = params[:query]
        page = params[:page].to_i or 1
        filters = params[:filters].split(',')

        if query.present?
          results = Listing.where("LOWER(title) LIKE :query", query: "%#{query.downcase}%")
        else
          results = Listing.all
        end

        if filters.include? 'plans'
          results = results.joins(:plan)
        end

        if filters.include? 'pending_claims'
          results = results.where(claim_status: :pending_verification)
        end

        results = results.order('title').page(page).per(25)

        render json: {
          listings: results.map { |l| l.as_json_admin },
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
        owner_id = listing_params[:owner_id]

        @listing = Listing.find params[:id]

        if listing_params[:regenerate_claim_id]
          @listing.regenerate_claim_id
        elsif owner_id
          owner = User.find_by(id: owner_id)

          if owner.present?
            @listing.owner = owner
            @listing.claim_status = :claimed
          else
            @listing.owner = nil
            @listing.claim_status = :unclaimed
          end
        else
          if listing_params[:visibility].present?
            @listing.assign_attributes({
              visibility: listing_params[:visibility]
            })
          end

          if listing_params[:slug].present?
            @listing.assign_attributes({
              slug: listing_params[:slug]
            })
          end

          if listing_params[:plan_type].present?
            price = listing_params[:price]

            if price.present?
              price = BigDecimal(price)
            end

            plan = Plan.find_or_create_by listing_id: @listing.id
            plan.assign_attributes({
              listing_id: @listing.id,
              plan_type: listing_params[:plan_type],
              price: price
            })

            plan.save
          elsif @listing.plan.present?
            @listing.plan.delete
          end
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
          :id,
          :owner_id,
          :plan_type,
          :price,
          :regenerate_claim_id,
          :slug,
          :visibility,
        )
      end
    end
  end
end
