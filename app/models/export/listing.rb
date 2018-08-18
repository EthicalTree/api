module Export
  class Listing < Export::BaseExporter

    def get_possible_fields
      {
        id: 'ID',
        slug: 'Slug',
        title: 'Title',
        plan_info: ['Plan Type', 'Plan Price', 'Plan Price (Override)'],
        claim_id: 'Claim ID',
        claim_url: 'Claim URL',
        visibility: 'Visibility'
      }
    end

    def get_items
      ::Listing.all
    end

    private

    def id item
      item.id
    end

    def slug item
      item.slug
    end

    def title item
      item.title
    end

    def plan_info item
      plan = item.plan

      if plan
        [plan.type[:name], "#{plan.type[:price]}", "#{plan.price}"]
      else
        ['', '']
      end
    end

    def claim_id item
      item.claim_id
    end

    def claim_url item
      item.claim_url
    end

    def visibility item
      item.visibility
    end
  end
end
