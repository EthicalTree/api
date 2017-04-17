class CreateListingLocation < ActiveRecord::Migration[5.0]
  def change
    create_table :listing_locations do |t|
      t.integer :listing_id, null: false
      t.integer :location_id, null: false
      t.timestamps
    end
  end
end
