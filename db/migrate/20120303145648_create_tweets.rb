class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.integer :user_id
      t.integer :room_id
      t.text :post

      t.timestamps
    end
  end
end
