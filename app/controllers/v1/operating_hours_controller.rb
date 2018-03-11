module V1
  class OperatingHoursController < APIController
    before_action :require_listing
    before_action :authenticate_user, only: %i{update create destroy}

    def index

    end

    def create
      authorize! :update, @listing
      operating_hours = operating_hours_params

      @listing.operating_hours = []

      operating_hours.to_h.each do |day, value|
        value["hours"].each do |v|
          hour = OperatingHours.new do |oh|
            oh.day = day
            oh.open = Time.parse(v[:open_str] + ' UTC')
            oh.close = Time.parse(v[:close_str] + ' UTC')
            oh.listing_id = @listing.id
          end

          @listing.operating_hours.push hour
        end
      end

      render json: { operating_hours: @listing.operating_hours.map{|o| o.as_json_full} }, status: :ok
    end

    def show

    end

    def update

    end

    def destroy

    end

    private

    def operating_hours_params
      content = {
        hours: [:open_str, :close_str]
      }

      params.require(:operating_hour).permit(
        sunday: content,
        monday: content,
        tuesday: content,
        wednesday: content,
        thursday: content,
        friday: content,
        saturday: content
      )
    end

    def require_listing
      @listing = Listing.published.find_by!(slug: params[:listing_id])
    end
  end
end
