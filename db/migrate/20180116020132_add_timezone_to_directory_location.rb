class AddTimezoneToDirectoryLocation < ActiveRecord::Migration[5.1]
  def change
    add_column :directory_locations, :timezone, :string
  end
end
