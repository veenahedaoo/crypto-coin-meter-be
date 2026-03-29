# frozen_string_literal: true

class CoinService
  def fetch_coins(symbol_name=nil, is_active=nil)
    CoinList.all.tap do |query|
      query.where!("symbol_name ILIKE ?", "#{symbol_name}%") if symbol_name.present?
      query.where!(is_active: is_active) unless is_active.nil?
    end
  end
end
