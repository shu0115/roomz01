class ChangeColumnTweets01 < ActiveRecord::Migration
  def up
    change_column :tweets, :from_twitter_image_url, :string, limit: 1024
    change_column :tweets, :user_image_url, :string, limit: 1024
  end

  def down
    change_column :tweets, :from_twitter_image_url, :string
    change_column :tweets, :user_image_url, :string
  end
end
