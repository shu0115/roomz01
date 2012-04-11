class ChangeColumnTweets01 < ActiveRecord::Migration
  def up
    change_column :tweets, :from_twitter_image_url, :text
    change_column :tweets, :user_image_url, :text
  end

  def down
    change_column :tweets, :from_twitter_image_url, :string
    change_column :tweets, :user_image_url, :string
  end
end
