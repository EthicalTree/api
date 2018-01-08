module V1
  class MenusController < APIController

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

    def menu_params
      params.require(:menu).permit(
        :title,
      )
    end

    def require_listing
      @listing = Listing.published.find_by!(slug: params[:id])
    end
  end
end
