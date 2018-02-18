class CreateCuratedList < ActiveRecord::Migration[5.1]
  def change
    create_table :curated_lists do |t|
      t.string :name
      t.string :description
      t.integer :tag_id
      t.integer :location
      t.integer :order
      t.boolean :hidden, default: true
      t.timestamps
    end
  end
end
