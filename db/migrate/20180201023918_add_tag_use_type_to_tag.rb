class AddTagUseTypeToTag < ActiveRecord::Migration[5.1]
  def change
    add_column :tags, :use_type, :integer, default: 0
  end
end
