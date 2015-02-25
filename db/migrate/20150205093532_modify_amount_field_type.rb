class ModifyAmountFieldType < ActiveRecord::Migration
  def up
    change_table :quotations do |t|
      t.change :amount, :decimal, precision: 20, scale: 0
      t.change :volume, :decimal, precision: 20, scale: 0
    end
  end
 
  def down
    change_table :quotations do |t|
      t.change :amount, :integer
      t.change :volume, :integer
    end
  end
end
