namespace :datamigrate do

  desc "Updates all listings with their appropriate DirectoryLocation city object"
  task :update_listings_with_city_directory_location, [] => [:environment] do |task, args|
    puts 'Starting listing city update...'
    puts ''

    listings = Listing.all

    progress = ProgressBar.create(
      starting_at: 0,
      total: listings.length
    )

    Listing.all.each do |listing|
      location = listing.location

      if location.present?
        directory_location, _ = Search.find_directory_location(
          location.city,
          is_city_scope: true
        )

        listing.directory_location = directory_location
        listing.save!
      end

      progress.increment
    end
  end

end
