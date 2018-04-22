namespace :datamigrate do

  desc "Adds menus"
  task :menus, [] => [:environment] do |task, args|
    # Connect to migration db and copy data
    puts 'Connecting to the db...'
    db = connect()
    puts 'Creating listings...'
    add_menus(db)

    puts 'Done!'
  end

  private

  def add_menus db
    Dir.foreach('menu_images').sort.map do |img|
      if img == '.' || img == '..'
        next
      end

      id = img.gsub('K', '').split('.png')[0].split('-')[0]
      slug = ''

      slug = db.query("
        SELECT post_title
        FROM #{TABLES[:listings]}
        WHERE post_id='#{id}'
      ").first[:post_title].parameterize

      listing = Listing.find_by(slug: slug)
      listing.menu

      puts listing.title

      image_file = File.open("menu_images/#{img}", 'r')

      key = "listings/#{listing.title.parameterize}/menus/#{listing.menu.id}/images/#{img}"

      if !image = Image.find_by(key: key)
        $fog_bucket.files.create({
          key: key,
          body: image_file.read,
          public: true
        })

        image = Image.new(key: key)
      end

      listing.menu.images.push(image)
    end
  end

  def connect
    db_config = Rails.configuration.database_configuration
    client = Mysql2::Client.new(db_config[Rails.env].merge({
      symbolize_keys: true,
      database: DBNAME
    }).dup)
  end

end
