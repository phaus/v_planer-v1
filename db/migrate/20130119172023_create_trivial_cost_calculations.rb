class CreateTrivialCostCalculations < ActiveRecord::Migration
  def self.up
    create_table :trivial_cost_calculations do |t|
      t.decimal :unit_price, :precision => 10, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :trivial_cost_calculations
  end
end
