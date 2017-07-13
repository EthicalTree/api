module V1
  class EthicalitiesController < APIController

    before_action :require_ethicality, only: %i{show update destroy}
    before_action :authenticate_user, only: %i{update create destroy}

    def index
      render json: Ethicality.all.as_json, status: 200
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

    def ethicality_params

    end

    def require_ethicality

    end

  end

end
