module V1
  module Admin
    class ExportsController < APIController
      before_action :authenticate_user
      before_action :ensure_admin

      def index
        format = params[:format]
        fields = params[:fields].split(',')
        type = params[:type]

        job = Job.start_job(ExportWorker, format, fields, type)

        render json: job, status: :ok
      end
    end
  end
end
