class AddPcountToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :pcount, :integer
  end
end
