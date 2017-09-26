class AddCreatorToListing < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :owner_id, :integer
  end
end
