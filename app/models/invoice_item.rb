class InvoiceItem < ActiveRecord::Base

  belongs_to :invoice

  belongs_to :process_item,
      :polymorphic => true

  validates_presence_of :price

  def price
    self.read_attribute(:price_i).to_f / 100
  end

  def price=(value)
    self.write_attribute(:price_i, value * 100)
  end

  def item=(pi)
    self.process_item = pi
    self.price_i = pi.price_i
  end

end
