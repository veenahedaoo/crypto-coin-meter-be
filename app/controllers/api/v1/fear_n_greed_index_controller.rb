class Api::V1::FearNGreedIndexController < ApplicationController
  def index
    fear_n_greed_index = FearNGreedIndexService.new.get_fear_n_greed_index
    fear_n_greed_index[:data].map do |ele|
      ele[:date] = Time.at(ele[:timestamp].to_i).in_time_zone('Asia/Kolkata').strftime('%d %b, %Y %I:%M %p')
    end
    time_until_update = fear_n_greed_index[:data][0][:time_until_update].to_i
    fear_n_greed_index[:data][0][:time_until_update] = "#{time_until_update / 3600}:#{(time_until_update % 3600) / 60}:#{time_until_update % 60}"
    week_sum = (fear_n_greed_index[:data].sum { |item| item[:value].to_i rescue 0 }) / 7
    week_classification = case week_sum
                          when 0..24
                            "Extreme Fear"
                          when 25..49
                            "Fear"
                          when 50..74
                            "Greed"
                          else
                            "Extreme Greed"
                          end
    unless fear_n_greed_index[:error]
      render json: {
        status: 200,
        data: fear_n_greed_index[:data],
        week_avg: {
          value: week_sum,
          value_classification: week_classification
        }
      }
    else
      render json: {
        status: 500,
        error: fear_n_greed_index[:error],
        message: fear_n_greed_index[:message]
      }
    end
  end
end
