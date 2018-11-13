class OperatingHours < ApplicationRecord
  belongs_to :listing

  def self.todays_hours
    today = Timezone.now.strftime('%A').downcase
    find_by day: today
  end

  def open_at_24_hour
    open_time.strftime('%H:%M')
  end

  def closed_at_24_hour
    close_time.strftime('%H:%M')
  end

  def hours
    "#{open_time.strftime('%I:%M %P')} - #{close_time.strftime('%I:%M %P')}"
  end

  def as_json_full
    as_json({
              methods: [
                :label,
                :open_at_24_hour,
                :closed_at_24_hour,
                :hours
              ]
            })
  end

  def label
    {
      sunday: 'Sunday',
      monday: 'Monday',
      tuesday: 'Tuesday',
      wednesday: 'Wednesday',
      thursday: 'Thursday',
      friday: 'Friday',
      saturday: 'Saturday'
    }[day.to_sym]
  end
end
