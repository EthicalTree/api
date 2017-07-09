class OperatingHours < ApplicationRecord
  belongs_to :listing

  def as_json_full
    as_json methods: [:label, :hours, :open_str, :close_str, :enabled]
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
