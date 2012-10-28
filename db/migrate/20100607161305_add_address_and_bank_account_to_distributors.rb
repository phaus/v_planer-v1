class AddAddressAndBankAccountToDistributors < ActiveRecord::Migration
  def self.up
    add_column :distributors, :address_id, :integer
    add_column :distributors, :bank_account_id, :integer
  end

  def self.down
    remove_column :distributors, :address_id
    remove_column :distributors, :bank_account_id
  end
end
