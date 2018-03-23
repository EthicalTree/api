class AddAddressToLocation < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :address, :string
    add_column :locations, :city, :string
    add_column :locations, :region, :string
    add_column :locations, :country, :string
  end
end
