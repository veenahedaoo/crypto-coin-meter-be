class Api::V1::ExchangesController < Api::V1::BaseController

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    exchange_name = params[:exchange_name]
    is_active = params[:is_active]
    exchanges = ExchangeService.new.search_exchange(exchange_name, is_active)
    pagy, records = pagy_countless(exchanges, items: per_page, page: page)
    render json: {
      data: records,
      next_page: pagy.next,
      prev_page: pagy.prev,
      page: pagy.page,
    }
  end

  def show
    exchange_id = params[:id]
    exchange_data = Exchange.find(exchange_id)
    if exchange_data[:updated_at] < 1.days.ago
      exchange_data_from_ext_res = CoinGeckoService.new.get_exchange_data(exchange_data.coingecko_exchange_id)
      merged_data = {
        year_established: exchange_data_from_ext_res[:year_established],
        country: exchange_data_from_ext_res[:country],
        description: exchange_data_from_ext_res[:description],
        url: exchange_data_from_ext_res[:url],
        image_url: exchange_data_from_ext_res[:image],
        facebook_url: exchange_data_from_ext_res[:facebook_url],
        reddit_url: exchange_data_from_ext_res[:reddit_url],
        twitter_handler: exchange_data_from_ext_res[:twitter_handler],
        coins: exchange_data_from_ext_res[:coins],
        pairs: exchange_data_from_ext_res[:pairs]
      }
      exchange_data.assign_attributes(merged_data)
      exchange_data.save if exchange_data.changed?
    end
    render json: {
      data: exchange_data,
      exchange_data_from_ext_res: exchange_data_from_ext_res,
    }
  rescue ActiveRecord::RecordNotFound => e
    render json: {
      status: 404,
      data: {}
    }
  end

end
