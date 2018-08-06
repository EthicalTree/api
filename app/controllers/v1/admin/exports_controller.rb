module V1
  module Admin
    class ExportsController < APIController

      before_action :authenticate_user
      before_action :ensure_admin

      def index
        format = params[:format]
        fields = params[:fields].split(',')
        type = params[:type]

        exporter = Export::Listing.new format, fields
        file_prefix = "#{type}"

        Tempfile.open(file_prefix, Rails.root.join('tmp')) do |fd|
          exporter.generate(fd)
          fd.rewind
          send_data fd.read, filename: "#{file_prefix}.#{format}"
        end
      end

    end
  end
end
