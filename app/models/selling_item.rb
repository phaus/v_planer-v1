class SellingItem < ActiveRecord::Base

  belongs_to :process
  belongs_to :product

  monetary_value :price, :unit_price

  def vat
    self.product.vat_rate * self.price
  end

end
