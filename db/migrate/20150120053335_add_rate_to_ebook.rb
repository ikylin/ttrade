class AddRateToEbook < ActiveRecord::Migration
  def change
    add_column :ebooks, :rate, :string
  end
end
