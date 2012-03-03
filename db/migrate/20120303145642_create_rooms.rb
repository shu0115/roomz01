class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.integer :user_id
      t.string :name
      t.string :hash_tag

      t.timestamps
    end
  end
end
