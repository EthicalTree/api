module V1
  module Admin
    class UsersController < APIController

      before_action :authenticate_user

      def index
        authorize! :read, User

        render json: User.all.map {|u| u.as_json(only: [:id, :email, :admin])}
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
