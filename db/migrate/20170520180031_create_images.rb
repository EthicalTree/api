class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.string :key

      t.timestamps
    end

    create_table :listing_images do |t|
      t.integer :listing_id
      t.integer :image_id

      t.timestamps
    end
  end
end
