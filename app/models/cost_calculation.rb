class RentalItemCostCalculation < CostCalculation

#   attr_accessor :

  def initialize(product, item, )

  end

  def total_net_price

  end

  def total_gross_price

  end

  def unit_price
    
  end

  def billed_duration
    DISCOUNT_RATES = {
       1 => 1.0,
       2 => 1.65,
       3 => 2.3,
       4 => 2.95,
       5 => 3.35,
       6 => 3.75,
       7 => 4.15,
       8 => 4.55,
       9 => 4.95,
      10 => 5.0
    }
  end

end

class SellingItemCostCalculation < CostCalculation

end

class ServiceItemCostCalculation < CostCalculation

end
