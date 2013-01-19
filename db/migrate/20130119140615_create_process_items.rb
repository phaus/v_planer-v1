class CreateProcessItems < ActiveRecord::Migration
  def self.up
    create_table :process_items do |t|
      t.integer :commercial_process_id
      t.integer :product_id
      t.string  :name
      t.string  :remarks
      t.decimal :quantity, :precision => 10, :scale => 2
      t.string  :unit
      t.integer :cost_calculation_id
      t.string  :cost_calculation_type
      t.decimal :vat_percentage, :precision => 4, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :process_items
  end
end
