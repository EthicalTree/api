module Export
  class Listing < Export::BaseExporter
    def get_possible_fields
      {
        id: 'ID',
        description: 'Description',
        slug: 'Slug',
        title: 'Title',
        plan_info: ['Plan Type', 'Plan Price', 'Plan Price (Override)'],
        claim: ['Claim ID', 'Claim URL', 'Claim Owner'],
        visibility: 'Visibility',
        website: 'Website',
        phone_number: 'Phone Number',
        ethicalities: 'Ethicalities',
        tags: 'Tags',
        address: 'Address',
        latlng: 'LatLng',
        city: 'City',
        images: 'Images',
        menu_images: 'Menu Images',
        facebook_uri: 'Facebook URI',
        operating_hours: 'Operating Hours',
      }
    end

    def get_items
      ::Listing.all
    end

    private

    def id item
      item.id
    end

    def description item
      item.bio
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
        ['', '', '']
      end
    end

    def claim item
      owner = item.owner ? item.owner.display_name_with_email : ''
      [item.claim_id, item.claim_url, owner]
    end

    def visibility item
      item.visibility
    end

    def website item
      item.website
    end

    def phone_number item
      item.phone
    end

    def ethicalities item
      item.ethicalities.map { |e| e.slug }.join(',')
    end

    def tags item
      item.tags.map { |t| t.hashtag }.join(',')
    end

    def address item
      item.address
    end

    def latlng item
      item.location.latlng if item.location
    end

    def city item
      item.city
    end

    def images item
      item.images.map { |i| i.url }.join('|')
    end

    def menu_images item
      item.menu.images.map { |i| i.url }.join('|')
    end

    def facebook_uri item
      item.facebook_uri
    end

    def operating_hours item
      item.operating_hours.to_json
    end
  end
end
