class ServiceItem < ActiveRecord::Base
  belongs_to :process,
      :polymorphic => true
  belongs_to :product

  collect_errors_from :product

  validates_presence_of :unit_price,
      :price,
      :product

  accepts_nested_attributes_for :product

  monetary_value :price,
      :unit_price

  def unit_price
    super || self.product.unit_price
  end

  def price
    super || self.unit_price * self.count * self.duration
  end

end
