class AddImagesToCollection < ActiveRecord::Migration[5.2]
  def change
    rename_table :curated_lists, :collections

    create_table :collection_images do |t|
      t.integer :collection_id
      t.integer :image_id

      t.timestamps
    end
  end
end
