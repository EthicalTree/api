module Export
  def self.new_by_type type, options
    model = {
      listings: Export::Listing,
      seo_paths: Export::SeoPath,
    }[type.to_sym]

    model.new(options)
  end

  class BaseExporter
    def initialize options
      @fields = options[:fields]
      @format = options[:format]
      @update_progress = options[:update_progress]
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
        items = get_items

        items.each_with_index do |item, i|
          csv << get_row(item)

          if @update_progress.present?
            @update_progress.call(i+1, items.length)
          end
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
