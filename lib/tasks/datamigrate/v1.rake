namespace :datamigrate do

  DBNAME = 'et_datamigrate_v1'

  ETHICALITIES = {
    'Veg-friendly': 'vegetarian',
    'Vegetarian': 'vegetarian',
    'Vegan': 'vegan',
    'Fair Trade options': 'fair_trade',
    'Fair trade': 'fair_trade',
    'Owned by a woman': 'woman_owned',
    'Woman-owned': 'woman_owned',
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
      featured_image: 'featured_image',
      lat: 'post_latitude',
      lng: 'post_longitude',
      operating_hours: 'geodir_timing',
      phone: 'geodir_contact',
      cover_image: 'featured_image',
      menu: 'geodir_menu',
      tags: 'post_tags',
      ethical_criteria: 'geodir_ethicalcriteria',
      website: 'geodir_website',
      address: 'post_address',
      city: 'post_city',
      region: 'post_region',
      country: 'post_country'
    },
    hours: {
      operating_hours: 'business_hours'
    },
    image: {
      url: 'file',
      order: 'menu_order'
    }
  }

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
    create_listings(domain, db)

    puts 'Done!'
  end

  private

  def create_listings domain, db
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

    results.each do |row|
      listing = get_or_create_listing row, domain, db
      listing.save
      listing.images.each {|i| i.save}
      print('.')
    end
  end

  def get_or_create_listing row, domain, db
    title = row[:post_title]
    status = row[:post_status]
    website = row[:geodir_website] || ''
    lat = row[:post_latitude].to_f
    lng = row[:post_longitude].to_f
    ethicalities = row[:geodir_ethicalcriteria].split(',')
    featured_image = row[:featured_image]
    tags = row[:post_tags].split(',')
    address = row[:post_address]
    city = row[:post_city]
    region = row[:post_region]
    country = row[:post_country]

    listing = Listing.find_by(slug: title.parameterize)

    if !listing
      listing = Listing.new
    end

    listing.update_attributes({
      title: title,
      bio: row[:post_content],
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
        oh.open = Time.parse(open1 + ' EST').utc
        oh.close = Time.parse(close1 + ' EST').utc
        results[0] = oh
      end

      if (open2.present? && close2.present?)
        oh = OperatingHours.new day: day
        oh.open = Time.parse(open2 + ' EST').utc
        oh.close = Time.parse(close2 + ' EST').utc
        results[1] = oh
      end

      results
    end.flatten.compact

    # Ethicalities
    ethicalities = ethicalities.map {|e| Ethicality.find_by(slug: ETHICALITIES[e.to_s.to_sym])}.compact

    location.update_attributes({
      lat: lat,
      lng: lng,
      timezone: 'America/Toronto',
      address: address,
      city: city,
      region: region,
      country: country
    })
    #DirectoryLocation.create_locations lat, lng
    listing.locations = [location]

    listing.ethicalities = ethicalities

    # Tags
    tags = tags.map {|t| Tag.find_or_create_by(hashtag: Tag.strip_hashes(t))}
    listing.tags = (tags + listing.tags)

    images = db.query("SELECT file,menu_order FROM #{TABLES[:images]} WHERE post_id='#{row[:post_id]}'").to_a

    listing.images = images.map do |image_row|
      name = "datamigrate_v1_#{image_row[:file].gsub('/', '_')}"
      key = "listings/#{listing.title.parameterize}/images/#{name}"
      order = image_row[:menu_order]

      res = HTTParty.get("https://#{domain}/wp-content/uploads/#{image_row[:file]}")

      $fog_bucket.files.create({
        key: key,
        body: res.body,
        public: true
      })

      if !image = Image.find_by(key: key)
        image = Image.new(key: key)
      end

      image.order = order
      image
    end.compact

    # generate the menu if it doens't exist
    listing.menu

    images = Nokogiri::HTML(row[:geodir_menu]).css('img').map do |image_tag|
      src = image_tag[:src]
      name = "datamigrate_v1_#{URI.parse(src).path.parameterize}"
      key = "listings/#{listing.title.parameterize}/menus/#{listing.menu.id}/images/#{name}"

      if !image = Image.find_by(key: key)
        begin
          res = HTTParty.get(src)
        rescue
          next
        end

        $fog_bucket.files.create({
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
    db = DBNAME

    `mysql -u #{username} --password="#{password}" --silent -e "DROP DATABASE IF EXISTS #{db}"`
    `mysql -u #{username} --password="#{password}" --silent -e "CREATE DATABASE #{db}"`
    `mysql -u #{username} --password="#{password}" --silent #{db} < #{sql_filename}`
  end

  def connect
    db_config = Rails.configuration.database_configuration
    client = Mysql2::Client.new(db_config[Rails.env].merge({
      symbolize_keys: true,
      database: DBNAME
    }).dup)
  end

end
