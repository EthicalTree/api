module V1
  module Admin
    class ImportsController < APIController

      before_action :authenticate_user
      before_action :ensure_admin

      def create
        fields = params[:fields].split(',')
        csv = params[:csv]
        type = params[:type]

        job = Job.start_job(ImportWorker, csv.read.bytes, fields, type)

        render json: job, status: :ok
      end
    end
  end
end
