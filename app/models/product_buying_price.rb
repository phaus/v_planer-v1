class ProductBuyingPrice < ActiveRecord::Base

  belongs_to :product

  belongs_to :distributor

  validates_presence_of :distributor_id

  def price
    (self.read_attribute(:price_i) || 0).to_f / 100.0
  end

  def price=(new_price)
    self.write_attribute :price_i, new_price.blank? ? nil : (new_price.sub(',', '.').to_f * 100)
  end

end
