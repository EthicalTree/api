module V1
  module Admin
    class CuratedListsController < APIController

      before_action :authenticate_user

      def index
        authorize! :read, CuratedList

        page = params[:page] or 1
        location = params[:location]

        results = CuratedList.where(location: location).page(page).per(25)
        results_hash = {}
        results_hash[location] = {
          data: results.map {|t| t.as_json(include: :tag)},
          current_page: page,
          total_pages: results.total_pages
        }

        render json: {
          curated_lists: results_hash,
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
        params[:curated_list].delete :hashtag

        @curated_list = CuratedList.find params[:id]
        @curated_list.assign_attributes curated_list_params

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
          :hashtag
        )
      end
    end
  end
end
