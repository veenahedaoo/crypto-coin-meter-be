# frozen_string_literal: true

class FearNGreedIndexService
  def get_fear_n_greed_index
    connection = Faraday.new("https://api.alternative.me")
    response = connection.get("fng/") do |req|
      req.params['limit'] = 7
    end
    JSON.parse(response.body, symbolize_names: true)
  rescue Faraday::ConnectionFailed => e
    {error: true, message: 'Connection failed. Please try again later.'}
  end
end
