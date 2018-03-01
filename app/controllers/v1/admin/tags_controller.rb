module V1
  module Admin
    class TagsController < APIController

      before_action :authenticate_user

      def index
        authorize! :read, Tag

        query = params[:query]
        page = params[:page] or 1

        if query.present?
          results = Tag.where("hashtag LIKE :query", query: "%#{query.downcase}%")
        else
          results = Tag.all
        end

        results = results.order('hashtag').page(page).per(25)
        render json: {
          tags: results.map {|t| t.as_json_admin},
          current_page: page,
          total_pages: results.total_pages
        }
      end

      def create
        authorize! :create, Tag
        tag_params[:hashtag] = Tag.strip_hashes(tag_params[:hashtag])
        @tag = Tag.find_or_create_by tag_params
        if @tag.save
          render json: { tag: @tag }, status: :ok
        else
          render json: { errors: @tag.errors.full_messages }
        end
      end

      def show

      end

      def update
        authorize! :update, Tag

        @tag = Tag.find params[:id]
        @tag.assign_attributes tag_params

        if @tag.save
          render json: {}
        else
          render json: { errors: @tag.errors.full_messages }
        end
      end

      def destroy
        authorize! :destroy, Tag
        @tag = Tag.find params[:id]
        @tag.delete
        render json: {}
      end

      private

      def tag_params
        params.require(:tag).permit(
          :hashtag,
          :use_type,
          :id
        )
      end
    end
  end
end
