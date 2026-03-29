class CoinGeckoService
  BASE_URL = "https://api.coingecko.com/api/v3/"
  def init_coins_list
    is_last_page = false
    page = 1
    per_page = 100
    max_attempts = 5
    attempts = 0
    connection = Faraday.new(url: BASE_URL)
    until is_last_page
      response = self.fetch_coins_from_api(connection, page, per_page)
      if response.is_a?(Hash) && response[:error]
        attempts += 1
        return if attempts >= max_attempts
        puts "Throttle limit reached Attempt to reconnect : #{attempts} "
        sleep 10 * attempts
        next
      end
      puts "Coins fetched successfully #{page}"
      attempts = 0
      parsed_response = JSON.parse(response.body, symbolize_names: true)
      data = parsed_response.map do |coin|
        {
          symbol: coin[:symbol],
          coingecko_symbol: coin[:id],
          symbol_name: coin[:name],
          icon_url: coin[:image],
          atl_date: coin[:atl_date],
          atl: coin[:atl],
          ath_date: coin[:ath_date],
          ath: coin[:ath],
          volume: coin[:total_volume],
          last_sync_time: Time.current,
          max_supply: coin[:max_supply],
          total_supply: coin[:total_supply],
        }
      end
      is_last_page = data.size < per_page
      CoinList.upsert_all(data, unique_by: :coingecko_symbol)
      page += 1
    end
  end

  private
  def fetch_coins_from_api(connection, page, per_page = 100)
    response = connection.get("coins/markets") do |req|
      req.headers['x-cg-demo-api-key'] = Rails.application.credentials.dig(:coingecko, :api_key)
      req.params['vs_currency'] = "usd"
      req.params['order'] = "id_asc"
      req.params['per_page'] = per_page
      req.params['page'] = page
    end
    if response.status == 429 || response.body.include?("Throttled")
      {error: true}
    else
      response
    end
  end
end