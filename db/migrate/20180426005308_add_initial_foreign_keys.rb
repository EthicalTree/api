def add_foreign_key_safe table, column, relation
  if !foreign_key_exists?(table, column: column)
    add_foreign_key table, relation
  end
end

class AddInitialForeignKeys < ActiveRecord::Migration[5.2]
  def up
    add_foreign_key_safe :operating_hours, :listing_id, :listings

    change_column :curated_lists, :tag_id, :bigint
    add_foreign_key_safe :curated_lists, :tag_id, :tags

    add_foreign_key_safe :listing_ethicalities, :ethicality_id, :ethicalities
    add_foreign_key_safe :listing_ethicalities, :listing_id, :listings

    add_foreign_key_safe :locations, :listing_id, :listings

    add_foreign_key_safe :listing_images, :image_id, :images
    add_foreign_key_safe :listing_images, :listing_id, :listings

    add_foreign_key_safe :menus, :listing_id, :listings
    change_column :menu_images, :menu_id, :bigint

    add_foreign_key_safe :menu_images, :menu_id, :menus
    add_foreign_key_safe :menu_images, :image_id, :images

    change_column :listing_tags, :tag_id, :bigint
    add_foreign_key_safe :listing_tags, :tag_id, :tags
    add_foreign_key_safe :listing_tags, :listing_id, :listings
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
