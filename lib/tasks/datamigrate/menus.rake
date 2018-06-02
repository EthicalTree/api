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

  desc "Adds menus V2"
  task :menus_v2, [:csv_file, :menu_dir] => [:environment] do |task, args|
    @csv_file = args[:csv_file]
    @menu_dir = args[:menu_dir]

    @images = Dir.entries(@menu_dir)

    # Connect to migration db and copy data
    puts 'Adding menus...'

    CSV.foreach(@csv_file, { headers: true, encoding: 'ISO8859-1' }) do |row|
      result = row.to_h.symbolize_keys

      title = to_utf8 result[:UniqueCount] || ''
      menu_id = result[:fiverr_menu_id]
      listing = Listing.find_by(slug: title.parameterize)

      if !listing || !menu_id.present?
        next
      end

      add_menu(listing, menu_id)
    end

    puts 'Done!'
  end

  private

  def add_menu listing, menu_id
    puts listing.slug
    image_filenames = @images.select {|f| f.starts_with?("#{menu_id}_") || f == "#{menu_id}.png"}
    listing.menu.images.delete_all

    images = image_filenames.map do |img|
      image_file = File.open("#{@menu_dir}/#{img}", 'r')

      puts img

      key = "listings/#{listing.slug}/menus/#{listing.menu.id}/images/#{img}"

      if !image = Image.find_by(key: key)
        $fog_images.files.create({
          key: key,
          body: image_file.read,
          public: true
        })

        image = Image.new(key: key)
      end

      image
    end

    listing.menu.images = images.reverse
    listing.menu.save
    listing.save
  end

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
        $fog_images.files.create({
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
