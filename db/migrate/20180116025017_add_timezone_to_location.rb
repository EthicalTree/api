class AddTimezoneToLocation < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :timezone, :string, default: 'UTC'
  end
end
