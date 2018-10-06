class NewOperatingHoursTimeColumns < ActiveRecord::Migration[5.2]
  def change
		add_column :operating_hours, :open_time, :time
		add_column :operating_hours, :close_time, :time
  end
end
