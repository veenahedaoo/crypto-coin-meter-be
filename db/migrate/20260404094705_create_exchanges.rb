class CreateExchanges < ActiveRecord::Migration[8.1]
  def change
    create_table :exchanges do |t|
      t.string :coingecko_exchange_id, null: false
      t.string :exchange_name, null: false
      t.boolean :enabled, default: false
      t.integer :year_established, default: 0
      t.string :country
      t.text :description
      t.string :url
      t.string :image_url
      t.string :facebook_url
      t.string :reddit_url
      t.string :twitter_handler
      t.integer :coins
      t.string :pairs
      t.timestamps
    end
  end
end
