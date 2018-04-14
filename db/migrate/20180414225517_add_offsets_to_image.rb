class AddOffsetsToImage < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :cover_offset_x, :integer, default: 0
    add_column :images, :cover_offset_y, :integer, default: 0
  end
end
