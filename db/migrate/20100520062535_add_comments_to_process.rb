class AddCommentsToProcess < ActiveRecord::Migration
  def self.up
    add_column :rentals, :offer_top_text,    :string, :default => nil
    add_column :rentals, :offer_bottom_text, :string, :default => nil
    add_column :rentals, :remarks,           :string, :default => nil

    add_column :sellings, :offer_top_text,    :string, :default => nil
    add_column :sellings, :offer_bottom_text, :string, :default => nil
    add_column :sellings, :remarks,           :string, :default => nil
  end

  def self.down
    remove_column :rentals, :offer_top_text
    remove_column :rentals, :offer_bottom_text
    remove_column :rentals, :remarks

    remove_column :selings, :offer_top_text
    remove_column :selings, :offer_bottom_text
    remove_column :selings, :remarks
  end
end
