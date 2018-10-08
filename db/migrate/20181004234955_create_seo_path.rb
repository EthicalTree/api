class CreateSeoPath < ActiveRecord::Migration[5.2]
  def change
    create_table :seo_paths do |t|
      t.string :path
      t.string :title
      t.string :description
      t.string :header
      t.timestamps
    end
  end
end
