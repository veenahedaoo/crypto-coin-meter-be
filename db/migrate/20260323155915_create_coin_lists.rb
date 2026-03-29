class CreateCoinLists < ActiveRecord::Migration[8.1]
  def change
    create_table :coin_lists do |t|
      t.string    :symbol, :null => false
      t.string    :coingecko_symbol, :null => false
      t.string    :symbol_name, :null => false
      t.date      :launch_date, :null => true
      t.date      :atl_date, :null => true
      t.numeric   :atl, :default => 0
      t.date      :ath_date, :null => true
      t.numeric   :ath, :null => true
      t.string    :volume, :null => true
      t.datetime  :last_sync_time, :null => false
      t.string    :icon_url, :null => true
      t.numeric   :max_supply, :null => true
      t.numeric   :total_supply, :null => true
      t.boolean   :is_active, :null => false, :default => true
      t.timestamps
    end
    add_index :coin_lists, :coingecko_symbol, :unique => true
    add_index :coin_lists, :symbol_name
  end
end
