class CreateMenus < ActiveRecord::Migration[5.1]
  def change
    create_table :menus do |t|
      t.integer :listing_id
      t.string :title

      t.timestamps
    end

    create_table :menu_images do |t|
      t.integer :menu_id
      t.integer :image_id

      t.timestamps
    end
  end
end
