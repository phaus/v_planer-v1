class AddTypeToCostCalculations < ActiveRecord::Migration
  def change
    add_column :trivial_cost_calculations, :type, :string
  end
end
