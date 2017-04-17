class CreateListingEthicality < ActiveRecord::Migration[5.0]
  def change
    create_table :listing_ethicalities do |t|
      t.integer :ethicality_key
      t.integer :listing_id
      t.timestamps
    end
  end
end
