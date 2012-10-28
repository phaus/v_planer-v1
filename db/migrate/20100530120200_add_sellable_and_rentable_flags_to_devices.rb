class AddSellableAndRentableFlagsToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :is_rentable, :boolean, :default => false
    add_column :devices, :is_sellable, :boolean, :default => false
  end

  def self.down
    remove_column :devices, :is_rentable
    remove_column :devices, :is_sellable
  end
end
