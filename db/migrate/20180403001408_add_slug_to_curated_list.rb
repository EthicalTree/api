class AddSlugToCuratedList < ActiveRecord::Migration[5.1]
  def change
    add_column :curated_lists, :slug, :string
  end
end
