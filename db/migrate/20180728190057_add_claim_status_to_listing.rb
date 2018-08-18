class AddClaimStatusToListing < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :claim_status, :integer, default: 0
  end
end
