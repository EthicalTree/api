module V1
  class LocationsController < APIController

    before_action :require_location, only: %i{show update destroy}

    def index

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

    def location_params

    end

    def require_location

    end

  end
end
