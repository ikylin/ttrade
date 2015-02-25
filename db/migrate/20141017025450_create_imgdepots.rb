class CreateImgdepots < ActiveRecord::Migration
  def change
    create_table :imgdepots do |t|
      t.string :titile
      t.text :summary

      t.timestamps
    end
    add_attachment :imgdepots, :imgfile
  end
end
