class CreateOperatingHours < ActiveRecord::Migration[5.0]
  def change
    create_table :operating_hours do |t|
      t.string :day
      t.time :open
      t.time :close
      t.integer :listing_id
      t.timestamps
    end
  end
end
