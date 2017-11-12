namespace :datamigrate do

  DBNAME = 'et_datamigrate_v1'

  ETHICALITIES = {
    'Veg-friendly': 'vegetarian',
    'Fair Trade options': 'fair_trade',
    'Owned by a woman': 'woman_owned',
    #'Organic options': 'organic',
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
      title: 'post_title',
      lat: 'post_latitude',
      lng: 'post_longitude',
      operating_hours: 'geodir_timing',
      phone: 'geodir_contact',
      cover_image: 'featured_image',
      menu: 'geodir_menu',
      ethical_criteria: 'geodir_ethicalcriteria'
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
      print('.')
    end
  end

  def get_or_create_listing row, domain, db
    title = row[:post_title]
    lat = row[:post_latitude].to_f
    lng = row[:post_longitude].to_f
    ethicalities = row[:geodir_ethicalcriteria].split(',')

    listing = Listing.find_by(slug: title.parameterize)

    if !listing
      listing = Listing.new
    end

    listing.update_attributes({
      title: title,
      bio: row[:post_content]
    })

    if listing.locations.present?
      location = listing.locations[0]
    else
      location = Location.new
    end

    business_hours = PHP.unserialize row[:business_hours]
    listing.operating_hours = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'].map do |day|
      is_open = business_hours["#{day}_closed"] == 'open'
      open = business_hours["#{day}_open"]
      close = business_hours["#{day}_close"]

      if !is_open || !open.present? || !close.present?
        next
      end

      if !oh = listing.operating_hours.find_by(day: day)
        oh = OperatingHours.new day: day
      end

      oh.open = Time.parse(open + ' UTC')
      oh.close = Time.parse(close + ' UTC')
      oh
    end.compact

    ethicalities = ethicalities.map {|e| Ethicality.find_by(slug: ETHICALITIES[e.to_s.to_sym])}.compact

    location.update_attributes lat: lat, lng: lng
    listing.locations = [location]
    listing.ethicalities = ethicalities

    images = db.query("SELECT file,menu_order FROM #{TABLES[:images]} WHERE post_id='#{row[:post_id]}'")
    listing.images = images.map do |image_row|
      name = "datamigrate_v1_#{image_row[:file].gsub('/', '_')}"
      key = "listings/#{listing.title.parameterize}/images/#{name}"
      order = image_row[:menu_order] - 1

      if !image = Image.find_by(key: key)
        res = HTTParty.get("https://#{domain}/wp-content/uploads/#{image_row[:file]}")

        $fog_bucket.files.create({
          key: key,
          body: res.body,
          public: true
        })

        image = Image.new(key: key)
      end

      image.order = order
      image
    end.compact

    # generate the menu if it doens't exist
    listing.menu

    listing.menu.images = Nokogiri::HTML(row[:geodir_menu]).css('img').map do |image_tag|
      src = image_tag[:src]
      name = "datamigrate_v1_#{URI.parse(src).path.parameterize}"
      key = "listings/#{listing.title.parameterize}/menus/#{listing.menu.id}/images/#{name}"

      if !image = Image.find_by(key: key)
        res = HTTParty.get(src)

        $fog_bucket.files.create({
          key: key,
          body: res.body,
          public: true
        })

        image = Image.new(key: key)
      end

      image
    end

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
