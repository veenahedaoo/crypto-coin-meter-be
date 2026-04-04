# frozen_string_literal: true

class ExchangeService
  def search_exchange(exchange_name=nil, is_active=nil)
    exchanges = Exchange.all
    exchanges.where(exchange_name: exchange_name) if exchange_name.present?
    exchanges.where(is_active: is_active) if is_active.present?
    exchanges.order(exchange_name: :desc)
  end

end
