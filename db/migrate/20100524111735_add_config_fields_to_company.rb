class AddConfigFieldsToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :rental_process_no_format, :string, :default => 'M-%id'
    add_column :companies, :selling_process_no_format, :string, :default => 'K-%id'
  end

  def self.down
    remove_column :companies, :rental_process_no_format
    remove_column :companies, :selling_process_no_format
  end
end
