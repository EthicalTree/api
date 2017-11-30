class CreateDirectoryLocation < ActiveRecord::Migration[5.1]
  def change
    create_table :directory_locations do |t|
      t.string :name

      t.float :boundlat1
      t.float :boundlng1

      t.float :boundlat2
      t.float :boundlng2

      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
