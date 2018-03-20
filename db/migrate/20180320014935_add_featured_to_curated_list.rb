class AddFeaturedToCuratedList < ActiveRecord::Migration[5.1]
  def change
    add_column :curated_lists, :featured, :boolean
  end
end
