class Api::V1::MarketDataController < ApplicationController
  def global_market_data
    data = CoinGeckoService.new.get_global_market_data
    data = data[:data] unless data[:error]
    data = {
      active_cryptocurrencies: data[:active_cryptocurrencies],
      markets: data[:markets],
      total_market_cap: data[:total_market_cap][:usd],
      total_volume: data[:total_market_cap][:usd],
      market_cap_percentage: data[:market_cap_percentage][:usdc],
      market_cap_change_percentage_24h_usd: data[:market_cap_change_percentage_24h_usd],
      volume_change_percentage_24h_usd: data[:volume_change_percentage_24h_usd],
      updated_at: Time.at(data[:updated_at]).strftime("%Y-%m-%d %H:%M:%S"),
    }
    render json: {
      status: 200,
      data: data,
    }
  end
end
