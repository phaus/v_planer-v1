class ReplaceIntegerUnitPriceWithDecimal_data < ActiveRecord::Migration
  def self.up
    dataset = [
      [:devices, :buying_price],
      [:devices, :selling_price],
      [:devices, :rental_price],
      [:expense_items, :price],
      [:invoice_items, :price],
      [:invoices, :price],
      [:product_buying_prices, :price],
      [:rental_periods, :unit_price],
      [:rental_periods, :price],
      [:rentals, :discount],
      [:rentals, :client_discount],
      [:selling_items, :price],
      [:selling_items, :unit_price],
      [:sellings, :discount],
      [:sellings, :price],
      [:sellings, :client_discount],
      [:service_items, :unit_price],
      [:service_items, :price],
      [:services, :unit_price] ]
    dataset.each do |model, attribute|
      ActiveRecord::Base.connection.execute "update #{model} set #{attribute} = #{attribute}_i / 100"
    end
  end

  def self.down
  end
end
