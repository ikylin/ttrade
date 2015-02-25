class AddIndexfilterIdToReserves < ActiveRecord::Migration
  def change
    add_column :reserves, :indexfilter_id, :integer
  end
end
