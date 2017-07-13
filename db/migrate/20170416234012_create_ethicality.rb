class CreateEthicality < ActiveRecord::Migration[5.0]
  def change
    create_table :ethicalities do |t|
      t.string :name
      t.string :slug
      t.string :icon_key
      t.timestamps
    end

    create_table :listing_ethicalities do |t|
      t.integer :listing_id
      t.integer :ethicality_id
      t.timestamps
    end
  end
end
