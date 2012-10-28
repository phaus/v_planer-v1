class Release031 < ActiveRecord::Migration
  def self.up
    # leftovers from release 3:
    remove_column :rental_periods, :price
    remove_column :rental_periods, :client_id
    remove_column :rental_periods, :device_id
    remove_column :devices, :owner_id
    remove_column :services, :owner_id
    drop_table :device_occupations
    drop_table :categories_devices

    add_column :company_sections, :vat_id,      :string, :size =>  50
    add_column :company_sections, :street,      :string, :size => 100
    add_column :company_sections, :postalcode,  :string, :size =>  20
    add_column :company_sections, :locality,    :string, :size => 100
    add_column :company_sections, :country,     :string, :size =>  50

  end

  def self.down
  end
end
