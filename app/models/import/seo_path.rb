module Import
  class SeoPath < Import::BaseImporter

    def get_possible_fields
      [
        :path,
        :title,
        :description,
        :header,
      ]
    end

    def get_item row
      path = ::SeoPath.strip_url(row['path'])

      if path.present?
        ::SeoPath.find_or_create_by path: path
      end
    end

    private

    def path item, value
      # no-op since this acts as an ID
    end

    def title item, value
      item.title = value
    end

    def description item, value
      item.description = value
    end

    def header item, value
      item.header = value
    end
  end
end
