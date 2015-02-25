class AddOpenidToWeixinlogs < ActiveRecord::Migration
  def change
    add_column :weixinlogs, :user_id, :integer
    add_column :weixinlogs, :openid, :string
    add_column :weixinlogs, :optquery, :string
    add_column :weixinlogs, :optreplay, :text
    add_column :weixinlogs, :opttime, :integer
    add_column :weixinlogs, :marketdate, :date
    remove_column :weixinlogs, :content, :text
    remove_column :weixinlogs, :time, :datetime
  end
end
