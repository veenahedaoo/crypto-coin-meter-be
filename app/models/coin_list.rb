class CoinList < ApplicationRecord
  validates :symbol, :presence => true
  validates :coingecko_symbol, :presence => true, uniqueness: true
  validates :symbol_name, :presence => true
end