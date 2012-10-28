class Release04 < ActiveRecord::Migration
  def self.up
    # leftovers from release 3:
    remove_column :categories_products, :id
    remove_column :rental_periods, :price
    remove_column :rental_periods, :device_id
    remove_column :devices, :is_container
    drop_table :device_containments
    drop_table :categories_devices

  end

  def self.down
    add_column :categories_products, :id, :integer
    create_table :categories_devices do |t|
      t.integer :device_id
      t.integer :category_id
    end
    add_column :rental_periods, :price, :float
    add_column :rental_periods, :device_id, :integer
    add_column :devices, :is_container, :boolean, :default => false
  end
end
