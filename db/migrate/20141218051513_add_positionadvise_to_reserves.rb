class AddPositionadviseToReserves < ActiveRecord::Migration
  def change
    add_column :reserves, :positionadvise, :decimal, precision: 3, scale: 2
  end
end
