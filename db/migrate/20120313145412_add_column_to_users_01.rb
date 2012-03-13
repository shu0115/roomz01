class AddColumnToUsers01 < ActiveRecord::Migration
  def change
    add_column :users, :token, :string
    add_column :users, :secret, :string
  end
end
