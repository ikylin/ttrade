class AddRiskrateToReserves < ActiveRecord::Migration
  def change
    add_column :reserves, :riskrate, :string
    add_column :reserves, :hhvadjust, :decimal, precision: 6, scale: 2
  end
end
