class Api::V1::ChartsController < Api::V1::BaseController
  def index
    params.require(:id)
    chart_type = params[:chart_type]
    symbol_id = params[:id]
    days = params[:days]
    symbol = CoinList.find(symbol_id)
    chart_data = CoinGeckoService.new.get_chart_data(symbol.coingecko_symbol, days, chart_type)
    render json: chart_data
  rescue ActionController::ParameterMissing
    render json: { error: 'id is missing' }, status: 400
  end
end
