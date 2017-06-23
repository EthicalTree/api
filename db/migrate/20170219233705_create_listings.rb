class CreateListings < ActiveRecord::Migration[5.0]
  def change
    create_table :listings do |t|
      t.string :title
      t.string :slug
      t.string :bio
      t.timestamps
    end
  end
end
