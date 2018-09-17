namespace :operating_hours do
  desc "Convert hours to the relative time from UTC"
  task correct_timezones: :environment do
    operating_hours = OperatingHours.all

    operating_hours.each do |oh|
      differential = oh.updated_at.dst? ? 5.hours : 4.hours

      oh.open -= differential
      oh.close -= differential

      oh.save
    end
  end
end
