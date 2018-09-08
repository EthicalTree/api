module V1
  class DirectoryLocationsController < APIController

    def index
      query = params[:query]
      name = params[:name]

      if name.present?
        directory_location, _ = Search.find_directory_location(name)
        render json: directory_location, status: :ok
      else
        results = DirectoryLocation.select(:name, :city, :id)

        results = results.where(
          "name LIKE :query",
          query: "%#{query}%"
        ).order(
          "CASE
            WHEN name LIKE #{Listing.connection.quote("#{query}%")} THEN 1
            WHEN name LIKE #{Listing.connection.quote("%#{query}%")} THEN 3
            ELSE 2
          END, name"
        )

        results = results.limit(6)
        render json: results.as_json, status: :ok
      end
    end

    def create

    end

    def show
      id = params[:id]
      render json: DirectoryLocation.find(id), status: :ok
    end

    def update

    end

    def destroy

    end

    private

  end
end
