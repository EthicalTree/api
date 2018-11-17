module V1
  module Admin
    class JobsController < APIController
      before_action :authenticate_user
      before_action :ensure_admin

      def show
        job = Job.find(params[:id])

        render json: job.as_json(methods: [:payload_object, :realtime_progress]), status: 200
      end
    end
  end
end
