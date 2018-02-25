class CreatePlan < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.belongs_to :listing, index: true
      t.string :plan_type
      t.decimal :price, precision: 16, scale: 2, default: 0.00
      t.timestamps
    end
  end
end
