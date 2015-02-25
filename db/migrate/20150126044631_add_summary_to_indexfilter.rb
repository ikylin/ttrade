class AddSummaryToIndexfilter < ActiveRecord::Migration
  def change
    add_column :indexfilters, :summary, :text
  end
end
