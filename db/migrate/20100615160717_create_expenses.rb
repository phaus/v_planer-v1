class CreateExpenses < ActiveRecord::Migration
  def self.up
    create_table :expenses do |t|
      t.string  :name
      t.string  :description
      t.float   :factor1,       :default => 1
      t.string  :unit1,         :default => nil
      t.string  :factor1_name
      t.float   :factor2,       :default => 1
      t.string  :unit2,         :default => nil
      t.string  :factor2_name
      t.float   :factor3,       :default => 1
      t.string  :unit3,         :default => nil
      t.string  :factor3_name
      t.float   :const1,        :default => 0
      t.string  :const1_name

      t.timestamps
    end

    create_table :expense_items do |t|
      t.integer :process_id
      t.string  :process_type
      t.integer :client_id
      t.integer :product_id
      t.float   :count1
      t.float   :factor1
      t.float   :count2
      t.float   :factor2
      t.float   :count3
      t.float   :factor3
      t.integer :const1
      t.integer :price_i
      t.timestamps
    end
  end

  def self.down
    drop_table :expenses
    drop_table :expense_items
  end
end
