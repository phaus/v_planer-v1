class ServiceItem < ActiveRecord::Base
  belongs_to :process,
      :polymorphic => true
  belongs_to :product

  collect_errors_from :product

  validates_presence_of :unit_price_i,
      :price_i,
      :product

  accepts_nested_attributes_for :product

  monetary_value :price,
      :unit_price

  def unit_price
    up = self.read_attribute(:unit_price_i)
    up ? up / 100.0 : self.product.unit_price
  end

  def price
    pi = self.read_attribute(:price_i)
    pi ? (pi / 100.0) : (self.unit_price * self.count * self.duration)
  end

end
