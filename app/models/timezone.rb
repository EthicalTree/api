class Timezone
  def self.now time_zone
    if !time_zone.present?
      time_zone = 'UTC'
    end

    Time.now.in_time_zone(time_zone)
  end
end
