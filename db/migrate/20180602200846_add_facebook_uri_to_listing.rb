class AddFacebookUriToListing < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :facebook_uri, :string
  end
end
