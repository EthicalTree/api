module Export
  class SeoPath < Export::BaseExporter
    def get_possible_fields
      {
        path: 'Path',
        title: 'Title',
        description: 'Description',
        header: 'Header',
      }
    end

    def get_items
      ::SeoPath.all
    end

    private

    def path item
      item.path
    end

    def title item
      item.title
    end

    def description item
      item.description
    end

    def header item
      item.header
    end
  end
end
