class CreateServiceItems < ActiveRecord::Migration
  def self.up
    create_table :service_items do |t|
      t.integer :process_id
      t.string  :process_type
      t.integer :client_id, :limit => 10
      t.integer :product_id, :limit => 10
      t.integer :count
      t.float   :duration
      t.text    :comments
      t.integer :unit_price_i
      t.integer :price_i

      t.timestamps
    end
  end

  def self.down
    drop_table :service_items
  end
end
