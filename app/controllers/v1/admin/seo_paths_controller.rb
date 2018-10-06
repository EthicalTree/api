module V1
  module Admin
    class SeoPathsController < APIController

      before_action :authenticate_user

      def index
        authorize! :read, SeoPath

        query = params[:query]
        page = params[:page] || 1

        if query.present?
          results = SeoPath.where("LOWER(path) LIKE :query", query: "%#{query.downcase}%")
        else
          results = SeoPath.all
        end

        results = results.order(:path).page(page).per(25)
        render json: {
          seo_paths: results.map {|t| t.as_json},
          current_page: page,
          total_pages: results.total_pages
        }
      end

      def create
        authorize! :create, SeoPath

        @seo_path = SeoPath.find_or_create_by seo_path_params

        if @seo_path.save
          render json: { seo_path: @seo_path.as_json }, status: :ok
        else
          render json: { errors: @seo_path.errors.full_messages }
        end
      end

      def show

      end

      def update
        authorize! :update, SeoPath

        @seo_path = SeoPath.find params[:id]
        @seo_path.assign_attributes seo_path_params

        if @seo_path.save
          render json: {}
        else
          render json: { errors: @seo_path.errors.full_messages }
        end
      end

      def destroy
        authorize! :destroy, SeoPath
        @seo_path = SeoPath.find params[:id]
        @seo_path.delete
        render json: {}
      end

      private

      def seo_path_params
        params.require(:seo_path).permit(
          :path,
          :title,
          :description,
          :header
        )
      end
    end
  end
end
