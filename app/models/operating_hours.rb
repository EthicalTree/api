class OperatingHours < ApplicationRecord
  belongs_to :listing

  validates :open_time, presence: true
  validates :close_time, presence: true
  validates :day, presence: true

  def self.todays_hours
    today = Timezone.now.strftime('%A').downcase
    find_by day: today
  end

  def self.from_facebook hours_hash
    days = {
      mon: 'monday',
      tue: 'tuesday',
      wed: 'wednesday',
      thu: 'thursday',
      fri: 'friday',
      sat: 'saturday',
      sun: 'sunday'
    }

    hours_hash.keys.map do |key|
      d, i, status = key.split('_')
      day = days[d.to_sym]

      if status == 'close'
        next
      end

      if status == 'open'
        oh = OperatingHours.new day: day
        oh.open_time = Time.parse(hours_hash[key] + ' UTC')
        oh.close_time = Time.parse(hours_hash["#{d}_#{i}_close"] + ' UTC')
        oh
      end
    end.compact
  end

  def self.from_google hours_hash
    days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ]

    periods = hours_hash['periods'] ? hours_hash['periods'] : []

    periods.map do |period|
      open = period['open'].merge({ status: 'open' })

      if period['close'].present?
        close = period['close'].merge({ status: 'close' })
      else
        close = open.merge({ status: 'close' })
      end

      oh = OperatingHours.new day: days[open['day'] || close['day']]

      [open, close].each do |hour|
        time_str = [hour['time'][0..1], hour['time'][2..-1]].join(':')
        time = Time.parse(time_str + ' UTC')

        if hour[:status] == 'open'
          oh.open_time = time
        elsif hour[:status] == 'close'
          oh.close_time = time
        end
      end

      oh
    end.compact
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
