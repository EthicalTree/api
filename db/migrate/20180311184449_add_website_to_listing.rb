class AddWebsiteToListing < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :website, :string
  end
end
