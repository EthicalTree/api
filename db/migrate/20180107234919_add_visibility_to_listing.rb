class AddVisibilityToListing < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :visibility, :integer, default: 0
  end
end
