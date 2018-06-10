module V1
  class DirectoryLocationsController < APIController

    def index
      location = params[:location]
      dl, _ = Search.find_directory_location(location)
      city = dl.present? ? dl.city : nil
      render json: { city: city }, status: :ok
    end

    def create

    end

    def show

    end

    def update

    end

    def destroy

    end

    private

  end
end
