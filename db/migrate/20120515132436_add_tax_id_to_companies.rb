class AddTaxIdToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :tax_id, :string
    add_column :companies, :vat_id, :string

    add_column :company_sections, :tax_id, :string
  end

  def self.down
    remove_column :company_sections, :tax_id

    remove_column :companies, :tax_id
    remove_column :companies, :vat_id
  end
end
