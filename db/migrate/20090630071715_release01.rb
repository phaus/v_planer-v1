class Release01 < ActiveRecord::Migration
  def self.up
    add_column :clients,        :client_no, :string
    add_column :rental_periods, :price,     :float, :default => 0.0
  end

  def self.down
    remove_column :clients,:client_no
    remove_column :rental_periods, :price
  end
end
