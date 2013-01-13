class InvoiceItem < ActiveRecord::Base
  belongs_to :invoice

  belongs_to :process_item,
      :polymorphic => true

  validates_presence_of :price

  def item=(pi)
    self.process_item = pi
    self.price = pi.price
  end

end
