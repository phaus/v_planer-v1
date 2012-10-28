class AddTitleToProcesses < ActiveRecord::Migration
  def self.up
    add_column :rentals, :title, :string, :default => ''
    add_column :sellings, :title, :string, :default => ''
  end

  def self.down
    remove_column :rentals, :title
    remove_column :sellings, :title
  end
end
