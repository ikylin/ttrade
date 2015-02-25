class AddMaxplratioToReserves < ActiveRecord::Migration
  def change
    add_column :reserves, :maxplratio, :decimal, precision: 6, scale: 2
  end
end
