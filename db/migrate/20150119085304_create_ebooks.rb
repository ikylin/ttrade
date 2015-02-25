class CreateEbooks < ActiveRecord::Migration
  def change
    create_table :ebooks do |t|
      t.string :title
      t.string :description
      t.string :wwwlink
      t.string :summary

      t.timestamps
    end
    add_attachment :ebooks, :frontcover
  end
end
