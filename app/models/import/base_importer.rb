module Import
  class BaseImporter
    def initialize options
      @csv = options[:csv].strip
      @fields = options[:fields]
      @update_progress = options[:update_progress]
      @possible_fields = get_possible_fields
    end

    def create_or_edit_row row
      item = get_item(row)

      if item.present?
        @fields.each do |field|
          if @possible_fields.include?(field.to_sym)
            self.send(field, item, row[field])
          end
        end

        item.save
      end
    end

    def import
      converter = lambda { |header| header.downcase }

      csv = CSV.parse(
        @csv,
        headers: true,
        header_converters: converter
      )

      csv.each_with_index do |row, i|
        create_or_edit_row(row)

        if @update_progress.present?
          @update_progress.call(i + 1, csv.length)
        end
      end
    end
  end
end
