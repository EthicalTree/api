module V1
  class PlansController < APIController

    def index
      render json: Plan.Types.map {|k, v| v.merge({ type: k })}, status: 200
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
