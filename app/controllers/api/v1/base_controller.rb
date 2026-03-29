class Api::V1::BaseController < ActionController::API

  protected
  def cast_boolean(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end

  def safe_integer(value)
    Integer(value)
  rescue ArgumentError, TypeError
    nil
  end
end
