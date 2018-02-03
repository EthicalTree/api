class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :hashtag
      t.timestamps
    end

    create_table :listing_tags do |t|
      t.integer :listing_id
      t.integer :tag_id
      t.timestamps
    end
  end
end
