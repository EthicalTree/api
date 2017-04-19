class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.integer :listing_id

      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
