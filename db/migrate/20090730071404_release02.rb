class Release3 < ActiveRecord::Migration
  def self.up
    remove_column :categories_devices, :id
    add_column :rental_periods, :rental_id, :integer, :limit => 10
    add_column :rental_periods, :count,     :integer, :limit => 10,  :default => 1
    add_column :devices, :owner_id,         :integer, :limit => 10
    add_column :devices, :available_count,  :integer, :limit => 10,  :default => 1
    add_column :devices, :manufacturer,     :string,  :limit => 50,  :default => ''
    add_column :devices, :buying_price_i,   :integer, :limit => 10
    add_column :devices, :selling_price_i,  :integer, :limit => 10
    add_column :devices, :rental_price_i,   :integer, :limit => 10,  :default => 0
    add_column :devices, :vat_rate,         :float,                  :default => 19.0
    add_column :devices, :unit,             :string,  :limit => 10,  :default => ''

    add_column :clients, :owner_id,         :integer, :limit => 10
    add_column :clients, :fax,              :string,  :limit => 16
    add_column :clients, :mobile,           :string,  :limit => 16
    add_column :clients, :homepage,         :string,  :limit => 100
    add_column :clients, :payment_goal,     :integer, :limit => 10,  :default => 0
    add_column :clients, :discount,         :integer, :limit => 10,  :default => 0
  end

  def self.down
    add_column :categories_devices, :id, :integer, :null => false, :auto_increment => true
    add_index :categories_devices, :id, :primary => true
  end
end
