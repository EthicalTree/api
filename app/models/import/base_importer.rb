module Import
  class BaseImporter
    def initialize csv, fields
      @csv = csv.read.strip
      @fields = fields
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
      converter = lambda {|header| header.downcase}

      CSV.parse(
        @csv,
        headers: true,
        header_converters: converter
      ).each do |row|
        create_or_edit_row(row)
      end
    end
  end
end
