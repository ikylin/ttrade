class AddEbookIdToEverydaytip < ActiveRecord::Migration
  def change
    add_column :everydaytips, :ebook_id, :integer
  end
end
