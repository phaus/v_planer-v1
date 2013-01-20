class RentalItemCostCalculation < ActiveRecord::Base
  include Conforming::ModelExtensions

  attr_accessor :item, :rental

  default_value_for :unit_price do
    self.item.product.unit_price || 0.0
  end

  def total_net_price
    self.unit_price * self.item.quantity * self.billed_duration
  end

  default_value_for :billed_duration do
    self.rental.billed_duration
  end

  default_value_for :usage_duration do
    self.rental.usage_duration
  end

end
