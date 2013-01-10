class ProductStockEntry < ActiveRecord::Base

  belongs_to :device

  scope :available_between, lambda {|from, to|
      where ['(select id from unavailabilities where product_stock_entry_id = product_stock_entries.id and unavailabilities.from_date < ? and unavailabilities.to_date > ?) is null', to, from]
  }

  validates_presence_of :device

end

