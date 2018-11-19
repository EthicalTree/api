module Import
  def self.new_by_type type, options
    model = {
      listings: Import::Listing,
      seo_paths: Import::SeoPath,
    }[type.to_sym]

    model.new(options)
  end

  class BaseImporter
    def initialize options
      @csv = options[:csv].strip
      @fields = options[:fields]
      @update_progress = options[:update_progress]
      @possible_fields = get_possible_fields
      @errors = []
    end

    def errors
      @errors
    end

    def create_or_edit_row row
      item = get_item(row)

      if item.present?
        begin
          @fields.each do |field|
            if @possible_fields.include?(field.to_sym)
              value = row[field.gsub('_', ' ')]
              if value.present?
                self.send(field, item, value)
              end
            end
          end

          item.save!
        rescue Exception => e
          e.message

          @errors.push({
            item: row,
            error_message: e.message,
            error_trace: e.backtrace.join('\r\n')
          })
        end
      end
    end

    def import
      converter = lambda { |header| header.downcase }

      detection = CharlockHolmes::EncodingDetector.detect(@csv)
      csv_content = CharlockHolmes::Converter.convert @csv, detection[:encoding], 'UTF-8'

      parsed_csv = CSV.parse(
        csv_content,
        encoding: "utf-8",
        headers: true,
        header_converters: converter
      )

      parsed_csv.each_with_index do |row, i|
        create_or_edit_row(row)

        if @update_progress.present?
          @update_progress.call(i + 1, parsed_csv.length)
        end
      end
    end
  end
end
