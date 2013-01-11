class ReplaceIntegerUnitPriceWithDecimal < ActiveRecord::Migration
  def self.up
    add_column :devices, :buying_price, :decimal, :precision => 10, :scale => 2
    add_column :devices, :selling_price, :decimal, :precision => 10, :scale => 2
    add_column :devices, :rental_price, :decimal, :precision => 10, :scale => 2
    add_column :expense_items, :price, :decimal, :precision => 10, :scale => 2
    add_column :invoice_items, :price, :decimal, :precision => 10, :scale => 2
    add_column :invoices, :price, :decimal, :precision => 10, :scale => 2
    add_column :product_buying_prices, :price, :decimal, :precision => 10, :scale => 2
    add_column :rental_periods, :unit_price, :decimal, :precision => 10, :scale => 2
    add_column :rental_periods, :price, :decimal, :precision => 10, :scale => 2
    add_column :rentals, :discount, :decimal, :precision => 10, :scale => 2
    add_column :rentals, :client_discount, :decimal, :precision => 10, :scale => 2
    add_column :selling_items, :price, :decimal, :precision => 10, :scale => 2
    add_column :selling_items, :unit_price, :decimal, :precision => 10, :scale => 2
    add_column :sellings, :discount, :decimal, :precision => 10, :scale => 2
    add_column :sellings, :price, :decimal, :precision => 10, :scale => 2
    add_column :sellings, :client_discount, :decimal, :precision => 10, :scale => 2
    add_column :service_items, :unit_price, :decimal, :precision => 10, :scale => 2
    add_column :service_items, :price, :decimal, :precision => 10, :scale => 2
    add_column :services, :unit_price, :decimal, :precision => 10, :scale => 2
  end

  def self.down
  end
end
