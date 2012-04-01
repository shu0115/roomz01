class CreateBatchLogs < ActiveRecord::Migration
  def change
    create_table :batch_logs do |t|
      t.string :name
      t.text :description
      t.timestamp :start_at
      t.timestamp :end_at
      t.float :process_time
      t.string :status
      t.text :result
      t.integer :total_count

      t.timestamps
    end
  end
end
