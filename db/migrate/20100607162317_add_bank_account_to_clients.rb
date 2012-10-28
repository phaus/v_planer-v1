class AddBankAccountToClients < ActiveRecord::Migration
  def self.up
    add_column :clients, :bank_account_id, :integer
  end

  def self.down
    remove_column :clients, :bank_account_id
  end
end
