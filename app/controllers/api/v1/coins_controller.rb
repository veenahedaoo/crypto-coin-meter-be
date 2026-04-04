class Api::V1::CoinsController < Api::V1::BaseController
  def index
    errors = validate_params
    return render json: {errors: errors}, status: :unprocessable_entity if errors.present?
    symbol_name = params[:symbol_name]&.strip
    is_active = cast_boolean(params[:is_active])
    page = safe_integer(params[:page]) || 1
    per_page = safe_integer(params[:per_page]) || 10
    coins = CoinService.new.fetch_coins(symbol_name, is_active)
    pagy , records = pagy_countless(coins, items: per_page, page: page)
    render json: {
      data: records,
      next_page: pagy.next,
      prev_page: pagy.prev,
      page: pagy.page,
    }
  end

  def show
    coin_id = params[:id]
    coin_data_from_db = CoinList.find(coin_id)
    coin_data_from_ext_res = CoinGeckoService.new.get_market_data(coin_data_from_db.coingecko_symbol)
    render json: {
      status: 200,
      data: {
        coin: coin_data_from_db,
        market_data: coin_data_from_ext_res[0],
      },
    }
  end

  # 1cd4cd896c21411aafeaeb661b2ef527 (News API Key (newsapi.org))
  private
  def validate_params
    page = safe_integer(params[:page])
    per_page = safe_integer(params[:per_page])
    errors = []
    errors << "page must be > 0" if page && page <= 0
    errors << "per_page must be >= 10" if per_page && per_page < 10
    errors << "is_active must be true or false " if params[:is_active].present? && cast_boolean(params[:is_active]).nil?
    errors
  end
end
