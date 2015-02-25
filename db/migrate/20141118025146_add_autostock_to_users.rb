class AddAutostockToUsers < ActiveRecord::Migration
  def change
    add_column :users, :autostock, :integer
  end
end
