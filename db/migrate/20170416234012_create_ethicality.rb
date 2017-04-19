class CreateEthicality < ActiveRecord::Migration[5.0]
  def change
    create_table :ethicalities do |t|
      t.string :name
      t.string :slug
      t.integer :listing_id
      t.timestamps
    end
  end
end
