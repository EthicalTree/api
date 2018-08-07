module Export
  class BaseExporter
    attr_accessor :FIELDS
    @FIELDS = {}

    def initialize format, fields
      @format = format
      @fields = fields
      @possible_fields = get_possible_fields
    end

    def get_headers
      @fields.map do |field|
        @possible_fields[field.to_sym]
      end.flatten
    end

    def get_row item
      @fields.map do |field|
        if @possible_fields.include?(field.to_sym)
          self.send(field, item)
        else
          ''
        end
      end.flatten
    end

    def generate_csv fd
      CSV(fd) do |csv|
        csv << get_headers
        get_items.each do |item|
          csv << get_row(item)
        end
      end
    end

    def generate fd
      if @format == 'csv'
        self.generate_csv fd
      end
    end
  end
end
