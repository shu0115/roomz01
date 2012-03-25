class AddColumnRoomsTweets < ActiveRecord::Migration
  def up
    # Room
    add_column :rooms, :search_query, :string
    add_column :rooms, :last_max_id, :integer, limit: 8
    add_column :rooms, :last_tweet_at, :timestamp
    add_column :rooms, :worker_flag, :boolean, default: false

    # Tweet
    add_column :tweets, :from_twitter_id, :integer, limit: 8
    add_column :tweets, :from_twitter_user_id, :integer, limit: 8
    add_column :tweets, :from_twitter_user, :string
    add_column :tweets, :user_image_url, :string
  end

  def down
    remove_column :rooms, :search_query
    remove_column :rooms, :last_max_id
    remove_column :rooms, :last_tweet_at
    remove_column :rooms, :worker_flag
    
    remove_column :tweets, :from_twitter_id
    remove_column :tweets, :from_twitter_user_id
    remove_column :tweets, :from_twitter_user
    remove_column :tweets, :user_image_url
  end
end
