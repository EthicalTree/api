class OperatingHours < ApplicationRecord
  belongs_to :listing

  status_choices = [
    :opening_soon,
    :open,
    :closing_soon,
    :closed
  ]

  def self.todays_hours time_zone='UTC'
    today = Timezone.now(time_zone).strftime('%A').downcase
    find_by day: today
  end

  def as_json_full
    as_json methods: [:label, :hours, :open_str, :close_str, :enabled]
  end

  def status time_zone='UTC', now=nil
    if !now
      now = Timezone.now time_zone
    end

    open_time = now.change(hour: open.hour, minute: open.min)
    opening_soon_time = open_time - 30.minutes
    close_time = now.change(hour: close.hour, minute: close.min)
    closing_soon_time = close_time - 30.minutes

    if now.between? opening_soon_time, open_time
      :opening_soon
    elsif now.between? closing_soon_time, close_time
      :closing_soon
    elsif now.between? open_time, close_time
      :open
    else
      :closed
    end
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

  def open_str
    if open then open.to_formatted_s(:operating_hours).downcase else nil end
  end

  def close_str
    if close then close.to_formatted_s(:operating_hours).downcase else nil end
  end

  def enabled
    !!(open && close)
  end

  def hours
    if open && close
      "#{open_str} - #{close_str}"
    else
      ''
    end
  end

end
