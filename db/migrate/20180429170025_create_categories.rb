class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :slug
      t.string :name
      t.timestamps
    end

    create_table :listing_categories do |t|
      t.belongs_to :listing, index: true
      t.belongs_to :category, index: true
      t.timestamps
    end
  end
end
