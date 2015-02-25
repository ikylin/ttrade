class AddRiskToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :psize, :integer
    add_column :accounts, :singlerisk, :decimal, precision: 6, scale: 2
  end
end
