module V1
  module Admin
    class CuratedListsController < APIController

      before_action :authenticate_user

      def index
        authorize! :read, CuratedList

        page = params[:page] || 1

        results = CuratedList.all.order(:order).page(page).per(25)

        render json: {
          curated_lists: results.map {|t| t.as_json(include: :tag)},
          current_page: page,
          total_pages: results.total_pages
        }
      end

      def create
        authorize! :create, CuratedList

        hashtag = curated_list_params[:hashtag]
        params[:curated_list].delete :hashtag

        @curated_list = CuratedList.find_or_create_by curated_list_params
        @curated_list.tag = Tag.find_by(hashtag: Tag.strip_hashes(hashtag))

        if @curated_list.save
          render json: { curated_list: @curated_list }, status: :ok
        else
          render json: { errors: @curated_list.errors.full_messages }
        end
      end

      def show

      end

      def update
        authorize! :update, CuratedList

        hashtag = curated_list_params[:hashtag]
        order = curated_list_params[:order]
        params[:curated_list].delete :hashtag
        params[:curated_list].delete :order

        @curated_list = CuratedList.find params[:id]
        @curated_list.assign_attributes curated_list_params

        if order.present?
          other_list = CuratedList.find_by(order: order)

          if other_list.present?
            other_list.update_column(:order, @curated_list.order)
            @curated_list.order = order
          end
        end

        if hashtag.present?
          @curated_list.tag = Tag.find_by(hashtag: Tag.strip_hashes(hashtag))
        end

        if @curated_list.save
          render json: {}
        else
          render json: { errors: @curated_list.errors.full_messages }
        end
      end

      def destroy
        authorize! :destroy, CuratedList
        @curated_list = CuratedList.find params[:id]
        @curated_list.delete
        render json: {}
      end

      private

      def curated_list_params
        params.require(:curated_list).permit(
          :id,
          :name,
          :description,
          :location,
          :hidden,
          :hashtag,
          :order
        )
      end
    end
  end
end
