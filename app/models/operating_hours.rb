class OperatingHours < ApplicationRecord
  belongs_to :listing

  def self.todays_hours
    today = Timezone.now.strftime('%A').downcase
    find_by day: today
  end

  def as_json_full
    as_json({
      methods: [
        :label,
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
