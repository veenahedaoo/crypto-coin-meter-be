class Exchange < ApplicationRecord
  validates :coingecko_exchange_id, :presence => true, uniqueness: true
  validates :exchange_name, :presence => true
end
