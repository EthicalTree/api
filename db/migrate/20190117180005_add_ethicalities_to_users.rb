class AddEthicalitiesToUsers < ActiveRecord::Migration[5.2]
  def change
    create_join_table :ethicalities, :users do |t|
      t.index :ethicality_id
      t.index :user_id
    end
  end
end
