# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::MarketData", type: :request do
  describe "GET /api/v1/global_market_data" do
    it "returns normalized global market data" do
      updated_at = 1_775_529_600
      payload = {
        data: {
          active_cryptocurrencies: 17_500,
          markets: 1_200,
          total_market_cap: { usd: 2_850_000_000_000.55 },
          total_volume: { usd: 120_000_000_000.25 },
          market_cap_percentage: { btc: 57.3, eth: 16.9, usdc: 4.2 },
          market_cap_change_percentage_24h_usd: 1.25,
          volume_change_percentage_24h_usd: -2.5,
          updated_at: updated_at
        }
      }
      service = instance_double(CoinGeckoService)

      expect(CoinGeckoService).to receive(:new).and_return(service)
      expect(service).to receive(:get_global_market_data).and_return(payload)

      get "/api/v1/global_market_data"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "status" => 200,
        "data" => {
          "active_cryptocurrencies" => 17_500,
          "markets" => 1_200,
          "total_market_cap" => 2_850_000_000_000.55,
          "total_volume" => 2_850_000_000_000.55,
          "market_cap_percentage" => 4.2,
          "market_cap_change_percentage_24h_usd" => 1.25,
          "volume_change_percentage_24h_usd" => -2.5,
          "updated_at" => Time.at(updated_at).strftime("%Y-%m-%d %H:%M:%S")
        }
      )
    end

    it "raises when the upstream service returns an error payload" do
      service = instance_double(CoinGeckoService)

      expect(CoinGeckoService).to receive(:new).and_return(service)
      expect(service).to receive(:get_global_market_data).and_return(error: true)

      expect do
        get "/api/v1/global_market_data"
      end.to raise_error(NoMethodError)
    end
  end
end
