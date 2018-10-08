namespace :operating_hours do
  desc "Convert hours to the relative time from UTC"
  task correct_timezones: :environment do
    operating_hours = OperatingHours.all

    puts("Altering Operating Hour times and moving open and close to open_time and close_time...")
    progress = ProgressBar.create(:starting_at => 0, :total => operating_hours.length)

    operating_hours.each do |oh|
      if !oh.listing_id
        oh.delete
      else
        differential = oh.updated_at.dst? ? 5.hours : 4.hours

        oh.open_time = oh.open - differential
        oh.close_time = oh.close - differential

        if !oh.save
          puts "#{oh.listing.slug}: #{oh.errors.full_messages}"
        end

        progress.increment
      end
    end
  end
end

namespace :operating_hours do
  desc "Convert hours to the relative time from UTC"
  task verify_timezones: :environment do
    OperatingHours.all.each do |oh|
      if !oh.open_time || !oh.close_time
        puts("open: #{oh.open}---#{oh.open_time}")
        puts("close: #{oh.close}---#{oh.close_time}")
      end
    end
  end
end






