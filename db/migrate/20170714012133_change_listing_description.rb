class ChangeListingDescription < ActiveRecord::Migration[5.0]
  def change
    change_column :listings, :bio, :text, limit: 65535
  end
end
