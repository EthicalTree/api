module Import
  class Listing < Import::BaseImporter
    def get_possible_fields
      [
        :id,
        :slug,
        :description,
        :visibility,
        :title,
        :website,
        :phone_number,
        :ethicalities,
        :tags,
        :address,
        :latlng,
        :facebook_hours,
        :google_hours,
        :images,
        :menu_images,
        :facebook_uri,
      ]
    end

    def get_item row
      id = row['id']
      facebook_uri = row['facebook_uri']
      slug = row['slug']
      title = row['title']

      if id.present?
        listing = ::Listing.find_by id: id
      elsif slug.present?
        listing = ::Listing.find_by slug: slug
      elsif facebook_uri.present?
        listing = ::Listing.find_by facebook_uri: facebook_uri
      elsif title.present?
        listing = ::Listing.find_by title: title
      else
        raise EthicalTreeImportException, "No identifier present in listing for import"
      end

      if !listing.present?
        listing = ::Listing.new title: title
      end

      listing
    end

    private

    def id item, value
      # no-op on the ID
    end

    def slug item, value
      # no-op on the slug since it is autogenerated
    end

    def description item, value
      item.bio = value.truncate(2000)
    end

    def title item, value
      item.title = value
    end

    def visibility item, value
      if value == 'published' || value == 'unpublished'
        item.visibility = value
      else
        item.visibility = ActiveModel::Type::Boolean.new.cast(value) ? :published : :unpublished
      end
    end

    def website item, value
      item.website = value
    end

    def phone_number item, value
      item.phone = value
    end

    def ethicalities item, value
      ethicalities = value.split(',')

      item.ethicalities = ethicalities.map do |e|
        Ethicality.by_name(e)
      end.compact
    end

    def tags item, value
      tags = value.split(',')

      item.tags = tags.map do |t|
        Tag.find_or_create_by(hashtag: Tag.strip_hashes(t))
      end.compact
    end

    def address item, value
      location = MapApi.build_from_address(value) if value.present?

      if location
        latlng = location[:latlng]
        item.set_location latlng[:lat], latlng[:lng]
      end
    end

    def latlng item, value
      lat, lng = value.split(',') if value.present?
      location = MapApi.build_from_coordinates(lat, lng) if lat.present? && lng.present?

      if location
        latlng = location[:latlng]
        item.set_location latlng[:lat], latlng[:lng]
      end
    end

    def images item, value
      value.split('|').map do |image_url|
        image = Image.create_by_url(image_url, {
          type: 'listing',
          slug: item.slug,
        })

        if image.present? && !item.images.find_by(key: image.key)
          image.order = item.images.length + 1
          item.images.push image
        end
      end
    end

    def menu_images item, value
      value.split('|').map do |image_url|
        image = Image.create_by_url(image_url, {
          type: 'menu',
          slug: item.slug,
          menu_id: item.menu.id
        })

        if image.present? && !item.menu.images.find_by(key: image.key)
          image.order = item.images.length + 1
          item.menu.images.push image
        end
      end
    end

    def facebook_hours item, value
      value = value.gsub("'", '"')
      hours = OperatingHours.from_facebook(JSON.parse(value))

      if hours.present?
        item.operating_hours.delete_all
        item.operating_hours = hours
      end
    end

    def google_hours item, value
      # Script has data with single quotes instead of double quotes
      value = value.gsub("'", '"').downcase
      hours = OperatingHours.from_google(JSON.parse(value))

      if hours.present?
        item.operating_hours.delete_all
        item.operating_hours = hours
      end
    end

    def operating_hours item, value
    end

    def facebook_uri item, value
      if value.present? && value.starts_with?('https://www.facebook.com/')
        value = value.gsub('https://www.facebook.com/', '')
      end

      item.facebook_uri = value
    end
  end
end