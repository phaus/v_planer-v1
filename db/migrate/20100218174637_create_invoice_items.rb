class CreateInvoiceItems < ActiveRecord::Migration
  def self.up
    create_table :invoice_items do |t|
      t.integer :process_item_id
      t.string :process_item_type
      t.integer :invoice_id
      t.integer :price_i
      t.string :remarks, :limit => 500

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_items
  end
end
