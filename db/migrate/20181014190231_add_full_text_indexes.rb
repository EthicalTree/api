class AddFullTextIndexes < ActiveRecord::Migration[5.2]
  def up
    remove_index :listings, :title if index_exists?(:listings, :title)
    remove_index :listings, :bio if index_exists?(:listings, :bio)
    remove_index :tags, :hashtag if index_exists?(:listings, :hashtag)

    add_index :listings, :title, type: :fulltext
    add_index :listings, :bio, type: :fulltext
    add_index :tags, :hashtag, type: :fulltext
  end

  def down
    remove_index :listings, :title if index_exists?(:listings, :title)
    remove_index :listings, :bio if index_exists?(:listings, :bio)
    remove_index :tags, :hashtag if index_exists?(:listings, :hashtag)
  end
end
