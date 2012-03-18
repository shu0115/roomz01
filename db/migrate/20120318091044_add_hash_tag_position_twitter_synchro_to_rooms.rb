class AddHashTagPositionTwitterSynchroToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :hash_tag_position, :string, default: "after"
    add_column :rooms, :twitter_synchro, :boolean, default: true
  end
end
