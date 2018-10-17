class AddDirectoryLocationToListing < ActiveRecord::Migration[5.2]
  def change
    add_reference :listings, :directory_location, foreign_key: true
  end
end
