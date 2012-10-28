class AddAddressDataToClient < ActiveRecord::Migration
  def self.up
    add_column :clients, :street,     :string
    add_column :clients, :postalcode, :string
    add_column :clients, :locality,   :string
  end

  def self.down
    remove_column :clients, :street
    remove_column :clients, :postalcode
    remove_column :clients, :locality
  end
end
