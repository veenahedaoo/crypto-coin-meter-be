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

  def get_market_data(coin_ids)
    connection = Faraday.new(url: BASE_URL)
    url = "coins/markets"
    response = connection.get(url) do |req|
      req.headers['x-cg-demo-api-key'] = Rails.application.credentials.dig(:coingecko, :api_key)
      req.params['vs_currency'] = "usd"
      req.params['ids'] = coin_ids
    end
    if response.status == 429
      {error: true}
    else
      JSON.parse(response.body, symbolize_names: true)
    end
  end

  def get_exchange_list
    connection = Faraday.new(url: BASE_URL)
    response = connection.get("exchanges/list") do |req|
      req.headers['x-cg-demo-api-key'] = Rails.application.credentials.dig(:coingecko, :api_key)
    end
    if response.status == 200
      response_json = JSON.parse(response.body, symbolize_names: true)
      response_json.each_slice(100) do |exchange_in_batch|
        exchange_data = exchange_in_batch.map do |exchange|
          {
            coingecko_exchange_id: exchange[:id],
            exchange_name: exchange[:name],
          }
        end
        Exchange.insert_all(exchange_data)
        puts "#{exchange_in_batch.length} Exchanges inserted"
      end
    end
  end

  def get_exchange_data(exchange_id)
    connection = Faraday.new(url: BASE_URL)
    response = connection.get("exchanges/#{exchange_id}") do |req|
      req.headers['x-cg-demo-api-key'] = Rails.application.credentials.dig(:coingecko, :api_key)
    end
    if response.status == 200
      JSON.parse(response.body, symbolize_names: true)
    else
      {error: true}
    end
  end

  def get_global_market_data
    connection = Faraday.new(url: BASE_URL)
    response = connection.get("global") do |req|
      req.headers['x-cg-demo-api-key'] = Rails.application.credentials.dig(:coingecko, :api_key)
    end
    if response.status == 200
      JSON.parse(response.body, symbolize_names: true)
    else
      {error: true}
    end
  end

  def get_chart_data(symbol_name, days=1, chart_type)
    connection = Faraday.new(url: BASE_URL)
    response = connection.get("coins/#{symbol_name}/market_chart") do |req|
      req.headers['x-cg-demo-api-key'] = Rails.application.credentials.dig(:coingecko, :api_key)
      req.params['vs_currency'] = "usd"
      req.params['days'] = days
    end
    if response.status == 200
      response_json = JSON.parse(response.body, symbolize_names: true)
      response_json[:prices].map do |price|
        price[0] = Time.at(price[0].to_i / 1000).in_time_zone('Asia/Kolkata').strftime('%d %b, %Y %I:%M %p')
      end if chart_type.nil? || chart_type == 'prices'
      response_json[:market_caps].map do |market_cap|
        market_cap[0] = Time.at(market_cap[0].to_i / 1000).in_time_zone('Asia/Kolkata').strftime('%d %b, %Y %I:%M %p')
      end if chart_type.nil? || chart_type == 'market_caps'
      response_json[:total_volumes].map do |volume|
        volume[0] = Time.at(volume[0].to_i / 1000).in_time_zone('Asia/Kolkata').strftime('%d %b, %Y %I:%M %p')
      end if chart_type.nil? || chart_type == 'total_volumes'
      chart_data = chart_type.present? ? response_json[chart_type.to_sym] : response_json
    end
    chart_data
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