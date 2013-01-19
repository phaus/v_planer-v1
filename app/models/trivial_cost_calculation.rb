class TrivialCostCalculation < ActiveRecord::Base
  include Conforming::ModelExtensions

  attr_accessor :item

  default_value_for :unit_price do
    0.0
  end

  def total_net_price
    self.unit_price * self.item.quantity
  end

end
