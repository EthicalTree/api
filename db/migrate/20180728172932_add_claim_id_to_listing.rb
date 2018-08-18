class AddClaimIdToListing < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :claim_id, :string
  end
end
