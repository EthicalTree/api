class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :job_type
      t.integer :status
      t.integer :progress
      t.text :payload
      t.text :error_msg
      t.text :error_stack_trace
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end
  end
end
