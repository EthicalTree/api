# frozen_string_literal: true

module V1
  module Admin
    class LocationsController < APIController
      before_action :authenticate_user

      def index
        authorize! :read, DirectoryLocation

        query = params[:query]
        location_type = params[:locationType]
        page = params[:page] || 1

        # this flag will return the "best guess" new
        # location information to create a new location
        recommended_location_latlng = params[:recommendedLocationLatlng]

        if recommended_location_latlng.present?
          lat, lng = recommended_location_latlng.split(',').map(&:to_f)

          details = MapApi.build_from_coordinates lat, lng

          if details[:city].present? && details[:state].present?
            name = "#{details[:city]}, #{details[:state]}"
            type = 'city'
          end

          if details[:sublocality].present? && details[:city].present?
            name = "#{details[:sublocality]}, #{details[:city]}"
            type = 'neighbourhood'
          end

          details = MapApi.build_from_address(name)

          return render json: {
            location: {
              name: name,
              timezone: details[:timezone],
              city: details[:city],
              neighbourhood: details[:sublocality],
              state: details[:state],
              country: details[:country],
              location_type: type,
              lat: details[:location]['lat'],
              lng: details[:location]['lng'],
              boundlat1: details[:bounds][:northeast]['lat'],
              boundlng1: details[:bounds][:northeast]['lng'],
              boundlat2: details[:bounds][:southwest]['lat'],
              boundlng2: details[:bounds][:southwest]['lng']
            }
          }
        end

        results = DirectoryLocation.all

        if query.present?
          results = results.where(
            'name LIKE :query',
            query: "%#{query.downcase}%"
          )
        end

        if location_type.present?
          results = results.where(
            'location_type = :location_type',
            location_type: location_type
          )
        end

        results = results.order(:name).page(page).per(25)
        render json: {
          locations: results.map(&:as_json),
          current_page: page,
          total_pages: results.total_pages
        }
      end

      def create
        authorize! :create, DirectoryLocation

        location = DirectoryLocation.new(location_params)

        if location.save
          render json: { location: location }
        else
          render json: { errors: location.errors.full_messages }
        end
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
          :timezone,
          :city,
          :state,
          :country,
          :neighbourhood,
          :location_type,
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
