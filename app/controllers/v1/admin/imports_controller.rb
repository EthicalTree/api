module V1
  module Admin
    class ImportsController < APIController

      before_action :authenticate_user
      before_action :ensure_admin

      def create
        fields = params[:fields].split(',')
        csv = params[:csv]

        importer = Import::SeoPath.new csv, fields
        importer.import()
      end
    end
  end
end
