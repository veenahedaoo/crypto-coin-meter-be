# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Charts", type: :request do
  describe "GET /api/v1/charts" do
    it "returns chart data for a valid coin id" do
      expected_payload = [["06 Apr, 2026 09:00 AM", 84_000.12]]
      coin = double("coin", coingecko_symbol: "bitcoin")
      service = instance_double(CoinGeckoService)

      allow(CoinList).to receive(:find).with("123").and_return(coin)
      expect(CoinGeckoService).to receive(:new).and_return(service)
      expect(service).to receive(:get_chart_data).with("bitcoin", "7", "prices").and_return(expected_payload)

      get "/api/v1/charts", params: { id: "123", days: 7, chart_type: "prices" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(expected_payload)
    end

    it "returns bad request when id is missing" do
      get "/api/v1/charts"

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq("error" => "id is missing")
    end

    it "passes a nil chart_type through to the service when omitted" do
      expected_payload = { "prices" => [["06 Apr, 2026 09:00 AM", 84_000.12]] }
      coin = double("coin", coingecko_symbol: "bitcoin")
      service = instance_double(CoinGeckoService)

      allow(CoinList).to receive(:find).with("123").and_return(coin)
      expect(CoinGeckoService).to receive(:new).and_return(service)
      expect(service).to receive(:get_chart_data).with("bitcoin", "30", nil).and_return(expected_payload)

      get "/api/v1/charts", params: { id: "123", days: 30 }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(expected_payload)
    end

    it "returns not found when the coin id does not exist" do
      allow(CoinList).to receive(:find).with("999").and_raise(ActiveRecord::RecordNotFound)

      get "/api/v1/charts", params: { id: "999", days: 7, chart_type: "prices" }

      expect(response).to have_http_status(:not_found)
    end
  end
end
