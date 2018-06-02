namespace :datamigrate do

  DBNAME = 'et_datamigrate_v1'

  DAYS = {
    mon: 'monday',
    tue: 'tuesday',
    wed: 'wednesday',
    thu: 'thursday',
    fri: 'friday',
    sat: 'saturday',
    sun: 'sunday'
  }

  ETHICALITIES = {
    'Veg-friendly': 'vegetarian',
    'Vegetarian': 'vegetarian',
    'Vegan': 'vegan',
    'Fair Trade options': 'fair_trade',
    'Fair Trade': 'fair_trade',
    'Fair trade': 'fair_trade',
    'Owned by a woman': 'woman_owned',
    'Woman-owned': 'woman_owned',
    'Woman-Owned': 'woman_owned',
    'Organic options': 'organic',
    'Organic': 'organic'
  }

  TABLES = {
    posts: 'wpnn_posts',
    hours: 'wpnn_postmeta',
    listings: 'wpnn_geodir_gd_place_detail',
    images: 'wpnn_geodir_attachments'
  }

  COLUMNS = {
    post: {
      description: 'post_content'
    },
    listing: {
      id: 'post_id',
      is_featured: 'is_featured',
      title: 'post_title',
      status: 'post_status',
      lat: 'post_latitude',
      lng: 'post_longitude',
      operating_hours: 'geodir_timing',
      phone: 'geodir_contact',
      menu: 'geodir_menu',
      tags: 'post_tags',
      ethical_criteria: 'geodir_ethicalcriteria',
      website: 'geodir_website',
      address: 'post_address',
      city: 'post_city',
      region: 'post_region',
      country: 'post_country',
      categories: 'gd_placecategory'
    },
    hours: {
      operating_hours: 'business_hours'
    },
    image: {
      url: 'file',
      order: 'menu_order'
    }
  }

  Sanitizer = Rails::Html::FullSanitizer.new

  desc "Copies data from V1 site to a V2 site"
  task :v1, [:sql_url, :domain, :username, :password, :nofetch] => [:environment] do |task, args|
    sql_url = args[:sql_url]
    domain = args[:domain]
    username = args[:username]
    password = args[:password]
    nofetch = !!args[:nofetch]

    auth = {username: username, password: password}

    if nofetch
      # Skip fetching of sql
      puts 'Skipping fetch of sql file...'
    else
      # Get sql backup
      puts 'Retrieving sql file...'
      res = HTTParty.get(sql_url, basic_auth: auth)
      sql_filename = extract(res)

      # Nuke backup db and load sql file
      puts 'Nuking and creating db...'
      replace_db sql_filename
    end

    # Connect to migration db and copy data
    puts 'Connecting to the db...'
    db = connect()
    puts 'Creating listings...'

    listing_fields = COLUMNS[:listing].values.map {|f| "#{TABLES[:listings]}.#{f}"}
    post_fields = COLUMNS[:post].values.map {|f| "#{TABLES[:posts]}.#{f}"}
    fields = (listing_fields + post_fields).join(',')
    fields = "#{fields},meta_value AS business_hours"

    results = db.query("
      SELECT #{fields} from #{TABLES[:posts]}
        JOIN #{TABLES[:listings]} ON #{TABLES[:posts]}.id=#{TABLES[:listings]}.post_id
        JOIN #{TABLES[:hours]} ON #{TABLES[:posts]}.id=#{TABLES[:hours]}.post_id AND
          #{TABLES[:hours]}.meta_key='business_hours'
    ")

    results = results.map do |row|
      # categories
      categories = row[:gd_placecategory].split(',').map {|c| c.present? ? c : nil}.compact
      row[:categories] = categories.map do |c|
        db.query("SELECT name, slug FROM wpnn_terms WHERE term_id=#{c}").to_a[0][:name]
      end

      # images
      row[:images] = db.query("SELECT file,menu_order FROM #{TABLES[:images]} WHERE post_id='#{row[:post_id]}'").to_a.map do |i|
        {
          uuid: i[:file],
          file: "https://#{domain}/wp-content/uploads/#{i[:file]}",
          order: i[:menu_order]
        }
      end

      row
    end

    create_listings(results)

    puts 'Done!'
  end

  desc "Copies data from V1 csv"
  task :v1_csv, [:csv_filename, :only] => [:environment] do |task, args|
    filename = args[:csv_filename]
    only = args[:only]
    results = []

    CSV.foreach(filename, { headers: true, encoding: 'ISO8859-1' }) do |row|
      result = row.to_h.symbolize_keys

      result[:geodir_ethicalcriteria] = (result[:Ethicalities] || "").gsub("\;", ",")
      result[:post_region] = 'Ontario'
      result[:post_title] = to_utf8 result[:UniqueCount]
      result[:post_content] = to_utf8 result[:"Final Description"]
      result[:post_tags] = (result[:"FinalTags"] || "").gsub("\;", ",")
      result[:categories] = (result[:"Business Type"] || "").split(";")
      result[:operating_hours] = result[:"FB hours (scraper)"]

      image_keys = result.keys.select {|k| k.to_s.starts_with?('IMAGE')}
      result[:images] = image_keys.map do |k|
        file = result[k]
        if file.present?
          {
            uuid: "#{Digest::SHA256.hexdigest(file)}.png",
            file: file,
            order: k.to_s.gsub('IMAGE', '').to_i
          }
        end
      end.compact

      results.push(result)
    end

    create_listings results, only: only
  end

  desc "Update images from our CSV import"
  task :v1_csv_update_images, [:csv_filename, :matcher_csv] => [:environment] do |task, args|
    filename = args[:csv_filename]
    matcher_filename = args[:matcher_csv]
    matcher_entries = CSV.read(matcher_filename, encoding: 'ISO8859-1')

    good = []
    bad = 0

    CSV.foreach(filename, { headers: true }) do |row|
      result = row.to_h.symbolize_keys
      name = result[:name]
      slug = name.parameterize
      hours = (result[:hours] || '').gsub("'", '"')
      images = result[:images]
      uri = result[:facebook_uri]
      should_replace = result[:facebook_uri].starts_with?('pages/')
      phone = ''

      listing = Listing.find_by(slug: slug)

      if !listing
        if uri.present?
          match = matcher_entries.select {|r| to_utf8(r[29] || '').include?(uri)}
        else
          match = []
        end

        if match.length > 0
          listing = Listing.find_by(slug: match[0][74].parameterize)
          phone = match[0][25] || ''

          if !listing
            bad += 1
            next
          end
        else
          bad += 1
          next
        end
      end

      if good.include?(listing.slug)
        next
      end

      good.push(listing.slug)

      writer << ["https://ethicaltree.com/listings/toronto/#{listing.slug}", "https://www.facebook.com/#{uri}"]

      next

      listing.facebook_uri = uri
      listing.phone = phone.gsub(/[\(\)\ \-\+\.]/, '')
      listing.phone = listing.phone.to_i.to_s

      if listing.phone.to_i == 0
        listing.phone = ''
      end

      listing.save

      puts slug

      if hours.present?
        save_facebook_business_hours(listing, JSON.parse(hours), dry=false)
      end

      if images.present?
        if should_replace
          cover = listing.cover_image
          old_images = listing.images.to_a

          if cover
            listing.images = [cover]
            listing.save

            old_images.each do |i|
              if i.id != cover.id
                i.destroy
              end
            end
            listing.reload
          end
        end

        listing.images.concat(images.split('|').map do |k|
          ext = File.extname(k.split('?')[0] || '')
          ext = ext.present? ? ext : 'jpg'
          uuid = "#{Digest::SHA256.hexdigest(k)}.#{ext}"
          name = "datamigrate_v1_#{uuid.gsub('/', '_')}"
          key = "listings/#{listing.title.parameterize}/images/#{name}"
          order = 1

          if (!listing.images.find_by(key: key))
            build_image k, key, order
          end
        end.compact)
        listing.save
      end
    end

    puts "Good: #{good.length}, Bad: #{bad}"
  end

  private

  def create_listings results, options={}
    results.each do |row|
      begin
        listing = get_or_create_listing row, options

        if !listing
          next
        end

        listing.save!
        listing.images.each {|i| i.save}
        listing.menu.images.each {|i| i.save}
      rescue => e
        if Rails.env == 'development'
          print('An error has occured')
          byebug
          print('Do some stuff')
        end
      end

      print('.')
    end
  end

  def get_or_create_listing row, options={}
    puts row[:post_title]
    title = row[:post_title]
    status = row[:post_status]
    website = row[:geodir_website] || ''
    lat = row[:post_latitude].to_f
    lng = row[:post_longitude].to_f
    ethicalities = row[:geodir_ethicalcriteria].split(',')
    tags = row[:post_tags].split(',')
    location = row[:location]
    address = row[:post_address]
    city = row[:post_city]
    region = row[:post_region]
    country = row[:post_country]
    categories = row[:categories]

    only = options[:only]

    bio = CGI.unescapeHTML(Sanitizer.sanitize(row[:post_content]))

    listing = Listing.find_by(slug: title.parameterize)

    if !listing && only
      return
    elsif !listing
      listing = Listing.new
    end

    # Ethicalities
    # TODO: separate each type of data into a function and wrap all of them
    if !only || only == 'ethicalities'
      ethicalities = ethicalities.map {|e| Ethicality.find_by(slug: ETHICALITIES[e.to_s.to_sym])}.compact
      listing.ethicalities = ethicalities

      if only == 'ethicalities'
        return listing
      end
    end

    listing.update_attributes({
      title: title,
      bio: bio.truncate(1999),
      website: website.downcase,
      visibility: if status == 'publish' then 'published' else 'unpublished' end
    })

    # Locations
    if listing.locations.present?
      location = listing.locations[0]
    else
      location = Location.new
    end

    # Business Hours
    if row[:business_hours]
      business_hours = PHP.unserialize row[:business_hours]

      listing.operating_hours.delete_all
      listing.operating_hours = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'].map do |day|
        is_open = business_hours["#{day}_closed"] == 'open'
        open1 = business_hours["#{day}_open"]
        close1 = business_hours["#{day}_close"]
        open2 = business_hours["#{day}_open_2"]
        close2 = business_hours["#{day}_close_2"]
        results = [nil, nil]

        if !is_open
          next
        end

        if (open1.present? && close1.present?)
          oh = OperatingHours.new day: day
          oh.open = Time.parse(open1 + ' EDT').utc
          oh.close = Time.parse(close1 + ' EDT').utc
          results[0] = oh
        end

        if (open2.present? && close2.present?)
          oh = OperatingHours.new day: day
          oh.open = Time.parse(open2 + ' EDT').utc
          oh.close = Time.parse(close2 + ' EDT').utc
          results[1] = oh
        end

        results
      end.flatten.compact
    elsif row[:operating_hours] && row[:operating_hours] != "0"
      business_hours = JSON.parse row[:operating_hours].gsub("'", '"')
      save_facebook_business_hours(listing, business_hours)
    end

    if location
      location.update_attributes({
        lat: location['latitude'],
        lng: location['longitude'],
        timezone: 'America/Toronto',
        address: location['street'],
        city: location['city'],
        region: 'Ontario',
        country: location['country'],
      })
    else
      location.update_attributes({
        lat: lat,
        lng: lng,
        timezone: 'America/Toronto',
        address: address,
        city: city,
        region: region,
        country: country
      })
    end

    DirectoryLocation.create_locations lat, lng
    listing.locations = [location]

    # Tags
    tags = tags.map {|t| Tag.find_or_create_by(hashtag: Tag.strip_hashes(t))}
    listing.tags = (tags + listing.tags)

    # Categories
    categories.each do |cat|
      category = Category.find_or_create_by(name: cat)
    end

    listing.images = row[:images].map do |image_row|
      name = "datamigrate_v1_#{image_row[:uuid].gsub('/', '_')}"
      key = "listings/#{listing.title.parameterize}/images/#{name}"
      order = image_row[:menu_order]
      original = image_row[:file]

      build_image(original, key, order)
    end.compact

    # generate the menu if it doens't exist
    listing.menu

    listing.menu.images = Nokogiri::HTML(row[:geodir_menu]).css('img').map do |image_tag|
      src = image_tag[:src]
      name = "datamigrate_v1_#{URI.parse(src).path.parameterize}"
      key = "listings/#{listing.title.parameterize}/menus/#{listing.menu.id}/images/#{name}"

      if !image = Image.find_by(key: key)
        begin
          res = HTTParty.get(src)
        rescue
          next
        end

        $fog_images.files.create({
          key: key,
          body: res.body,
          public: true
        })

        image = Image.new(key: key)
      end

      image
    end.compact

    listing
  end

  def save_facebook_business_hours listing, business_hours, dry=false
    if !dry
      listing.operating_hours.delete_all
    end

    operating_hours = business_hours.keys.map do |key|
      d, i, status = key.split('_')
      day = DAYS[d.to_sym]

      if status == 'close'
        next
      end

      if status == 'open'
        oh = OperatingHours.new day: day
        oh.open = Time.parse(business_hours[key] + ' EDT').utc
        close_key = "#{d}_#{i}_close"
        oh.close = Time.parse(business_hours[close_key] + ' EDT').utc
        oh
      end
    end.compact

    if !dry
      listing.operating_hours = operating_hours
      listing.save
    end

    operating_hours
  end

  def build_image original, key, order
    begin
      res = HTTParty.get(original)
    rescue

    end

    $fog_images.files.create({
      key: key,
      body: res.body,
      public: true
    })

    if !image = Image.find_by(key: key)
      image = Image.new(key: key)
    end

    image.order = order
    image
  end

  def extract res
    t = Tempfile.new ['et_datamigrate_v1', '.sql.bz2']
    t.binmode
    t << res.body
    t.rewind

    `bunzip2 #{t.path}`
    t.path.gsub('.bz2', '')
  end

  def replace_db sql_filename
    db_config = Rails.configuration.database_configuration

    username = db_config[Rails.env]["username"]
    password = db_config[Rails.env]["password"]
    host = db_config[Rails.env]["host"]
    db = DBNAME

    `mysql -u #{username} -h #{host} --password="#{password}" --silent -e "DROP DATABASE IF EXISTS #{db}"`
    `mysql -u #{username} -h #{host} --password="#{password}" --silent -e "CREATE DATABASE #{db}"`
    `mysql -u #{username} -h #{host} --password="#{password}" --silent #{db} < #{sql_filename}`
  end

  def connect
    db_config = Rails.configuration.database_configuration
    client = Mysql2::Client.new(db_config[Rails.env].merge({
      symbolize_keys: true,
      database: DBNAME
    }).dup)
  end

  def to_utf8(msg)
    msg.encode("iso-8859-1").force_encoding("utf-8")
  end

end
