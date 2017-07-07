class AddOrderToImage < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :order, :integer
  end
end
