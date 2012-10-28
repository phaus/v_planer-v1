class Unavailability < ActiveRecord::Base

  belongs_to :rental_period

  belongs_to :product_stock_entry

  validates_presence_of :rental_period, :product_stock_entry, :from_date, :to_date

end
