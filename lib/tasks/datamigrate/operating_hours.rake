namespace :operating_hours do
  desc "Convert hours to the relative time from UTC"
  task correct_timezones: :environment do
    operating_hours = OperatingHours.all

    puts("Altering Operating Hour times and moving open and close to open_time and close_time...")
    progress = ProgressBar.create(:starting_at => 0, :total => operating_hours.length)

    operating_hours.each do |oh|
      differential = oh.updated_at.dst? ? 5.hours : 4.hours

      oh.open_time = oh.open - differential
      oh.close_time = oh.close - differential

      oh.save
      progress.increment
    end
  end
end


# quick way to visually see if the new times were copied over
# operating_hours.each do |oh|
#   puts("open: #{oh.open}---#{oh.open_time}")
#   puts("close: #{oh.close}---#{oh.close_time}")
# end

