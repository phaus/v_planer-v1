class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.date :date
      t.integer :client_id
      t.integer :sender_id
      t.integer :user_id
      t.integer :process_id
      t.string  :process_type, :limit => 50
      t.integer :price_i
      t.string :remarks, :limit => 1000

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
