class AddCityToDirectoryLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :directory_locations, :neighbourhood, :string
    add_column :directory_locations, :city, :string
    add_column :directory_locations, :state, :string
    add_column :directory_locations, :country, :string

    add_column :directory_locations, :location_type, :string
    add_index :directory_locations, :location_type
  end
end
