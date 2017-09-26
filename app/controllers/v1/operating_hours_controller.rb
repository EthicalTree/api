module V1
  class OperatingHoursController < APIController

    before_action :require_listing
    before_action :has_permission, only: %i{create}

    def index

    end

    def create
      authorize! :update, @listing
      operating_hours = operating_hours_params

      p operating_hours

      @listing.operating_hours = []

      operating_hours.to_h.each do |k, v|
        hour = OperatingHours.new do |oh|
          oh.day = k
          oh.open = if v[:enabled] then Time.parse(v[:open_str] + ' UTC') else nil end
          oh.close = if v[:enabled] then Time.parse(v[:close_str] + ' UTC') else nil end
          oh.listing_id = @listing.id
        end

        @listing.operating_hours.push hour
      end

      p @listing.operating_hours

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

      content = [:open_str, :close_str, :enabled]

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
      if not @listing = Listing.find_by!(slug: params[:listing_id])
        not_found
      end
    end

    def has_permission
      if not current_user.can_edit_listing
        not_found
      end
    end

  end
end
