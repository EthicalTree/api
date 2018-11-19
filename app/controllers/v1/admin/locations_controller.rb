# frozen_string_literal: true

module V1
  module Admin
    class LocationsController < APIController
      before_action :authenticate_user

      def index
        authorize! :read, DirectoryLocation

        query = params[:query]
        page = params[:page] || 1

        if query.present?
          results = DirectoryLocation.where('name LIKE :query', query: "%#{query.downcase}%")
        else
          results = DirectoryLocation.all
        end

        results = results.order(:name).page(page).per(25)
        render json: {
          locations: results.map { |t| t.as_json },
          current_page: page,
          total_pages: results.total_pages
        }
      end

      def create
        authorize! :create, DirectoryLocation
        lat = params[:lat]
        lng = params[:lng]

        locations = DirectoryLocation.create_locations(lat, lng)

        render json: {
          location: locations.first
        }
      end

      def show; end

      def update
        authorize! :update, DirectoryLocation

        @location = DirectoryLocation.find params[:id]
        @location.assign_attributes location_params

        if @location.save
          render json: {}
        else
          render json: { errors: @location.errors.full_messages }
        end
      end

      def destroy
        authorize! :destroy, DirectoryLocation
        @location = DirectoryLocation.find params[:id]
        @location.delete
        render json: {}
      end

      private

      def location_params
        params.require(:location).permit(
          :name,
          :boundlat1,
          :boundlng1,
          :boundlat2,
          :boundlng2,
          :lat,
          :lng,
          :id
        )
      end
    end
  end
end
