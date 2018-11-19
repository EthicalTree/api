module V1
  module Admin
    class CollectionsController < APIController
      before_action :authenticate_user

      def index
        authorize! :read, Collection

        query = params[:query]
        page = params[:page] || 1

        if query.present?
          results = Collection.where("LOWER(name) LIKE :query", query: "%#{query.downcase}%")
        else
          results = Collection.all
        end

        results = results.order(:order).page(page).per(25)

        render json: {
          collections: results.map { |c| c.as_json_full },
          current_page: page,
          total_pages: results.total_pages
        }
      end

      def create
        authorize! :create, Collection

        hashtag = collection_params[:hashtag]
        params[:collection].delete :hashtag

        @collection = Collection.find_or_create_by collection_params
        @collection.tag = Tag.find_or_create_by(hashtag: Tag.strip_hashes(hashtag))

        if @collection.save
          render json: { collection: @collection.as_json_full }, status: :ok
        else
          render json: { errors: @collection.errors.full_messages }
        end
      end

      def show
      end

      def update
        authorize! :update, Collection

        featured = collection_params[:featured]
        hashtag = collection_params[:hashtag]
        order = collection_params[:order]
        params[:collection].delete :hashtag
        params[:collection].delete :order

        if featured == true
          Collection.update_all featured: false
        end

        @collection = Collection.find params[:id]
        @collection.assign_attributes collection_params

        if order.present?
          other_list = Collection.find_by(order: order)

          if other_list.present?
            other_list.update_column(:order, @collection.order)
            @collection.order = order
          end
        end

        if hashtag.present?
          @collection.tag = Tag.find_or_create_by(hashtag: Tag.strip_hashes(hashtag))
        end

        if @collection.save
          render json: { collection: @collection.as_json_full }
        else
          render json: { errors: @collection.errors.full_messages }
        end
      end

      def destroy
        authorize! :destroy, Collection
        @collection = Collection.find params[:id]
        @collection.delete
        render json: {}
      end

      private

      def collection_params
        params.require(:collection).permit(
          :id,
          :name,
          :description,
          :location,
          :hidden,
          :featured,
          :hashtag,
          :order
        )
      end
    end
  end
end
