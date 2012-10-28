class AddProcessNoToProcessesAndRentalNoToRentals < ActiveRecord::Migration
  def self.up
    add_column :rentals,  :process_no, :string
    add_column :sellings, :process_no, :string
    add_column :invoices, :invoice_no, :string
  end

  def self.down
    remove_column :rentals,  :process_no
    remove_column :sellings, :process_no
    remove_column :invoices, :invoice_no
  end
end
