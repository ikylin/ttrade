class CreateIndexfilters < ActiveRecord::Migration
  def change
    create_table :indexfilters do |t|
      t.string :name
      t.text :script
      t.string :platform
      t.integer :samplecount
      t.integer :wincount
      t.integer :losscount
      t.integer :marketdatecount

      t.timestamps
    end
  end
end
