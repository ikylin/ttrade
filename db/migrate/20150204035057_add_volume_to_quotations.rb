class AddVolumeToQuotations < ActiveRecord::Migration
  def change
    add_column :quotations, :volume, :integer
    add_column :quotations, :amount, :integer
  end
end
