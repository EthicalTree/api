module V1
  class SeoPathsController < APIController
    def index
      render json: SeoPath.all.as_json, status: 200
    end

    def create

    end

    def show

    end

    def update

    end

    def destroy

    end

  end

end
