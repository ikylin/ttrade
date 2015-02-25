class ModifyEbooks < ActiveRecord::Migration
  def change
    change_column :ebooks, :description, :text
    change_column :ebooks, :summary, :text
  end
end
