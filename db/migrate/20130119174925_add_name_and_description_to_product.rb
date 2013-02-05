class AddNameAndDescriptionToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :name, :string
    add_column :products, :description, :string
    add_column :products, :long_description, :string
    add_column :products, :internal_remarks, :string
  end

  def self.down
    remove_column :products, :name
    remove_column :products, :description
    remove_column :products, :long_description
    remove_column :products, :internal_remarks
  end
end
