class AddInitialForeignKeys < ActiveRecord::Migration[5.2]
  def up
    add_foreign_key :operating_hours, :listings

    change_column :curated_lists, :tag_id, :bigint
    add_foreign_key :curated_lists, :tags

    add_foreign_key :listing_ethicalities, :ethicalities
    add_foreign_key :listing_ethicalities, :listings

    add_foreign_key :locations, :listings

    add_foreign_key :listing_images, :images
    add_foreign_key :listing_images, :listings

    add_foreign_key :menus, :listings
    change_column :menu_images, :menu_id, :bigint

    add_foreign_key :menu_images, :menus
    add_foreign_key :menu_images, :images

    change_column :listing_tags, :tag_id, :bigint
    add_foreign_key :listing_tags, :tags
    add_foreign_key :listing_tags, :listings
  end

  def down
    remove_foreign_key :operating_hours, column: :listing_id

    remove_foreign_key :curated_lists, column: :tag_id
    change_column :curated_lists, :tag_id, :integer

    remove_foreign_key :listing_ethicalities, column: :ethicality_id
    remove_foreign_key :listing_ethicalities, column: :listing_id

    remove_foreign_key :locations, column: :listing_id

    remove_foreign_key :listing_images, column: :image_id
    remove_foreign_key :listing_images, column: :listing_id

    remove_foreign_key :menus, column: :listing_id

    remove_foreign_key :menu_images, column: :menu_id
    change_column :menu_images, :menu_id, :integer
    remove_foreign_key :menu_images, column: :image_id

    remove_foreign_key :listing_tags, column: :tag_id
    remove_foreign_key :listing_tags, column: :listing_id
    change_column :listing_tags, :tag_id, :integer
  end
end
