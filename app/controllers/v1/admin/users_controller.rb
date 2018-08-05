module V1
  module Admin
    class UsersController < APIController

      before_action :authenticate_user

      def index
        authorize! :read, User

        query = params[:query]
        page = params[:page] or 1
        page_size = params[:page_size] or 25

        if query.present?
          results = User.where("LOWER(email)LIKE :query", query: "%#{query.downcase}%")
        else
          results = User.all
        end

        results = results.order('email').page(page).per(page_size)
        render json: {
          users: results.as_json,
          current_page: page,
          total_pages: results.total_pages
        }
      end

      def create
      end

      def show

      end

      def update
        authorize! :update, User

        @user = User.find params[:id]
        @user.assign_attributes user_params

        if @user.save
          render json: {}
        else
          render json: { errors: @user.errors.full_messages }
        end
      end

      def destroy

      end

      private

      def user_params
        params.require(:user).permit(
          :admin
        )
      end
    end
  end
end
