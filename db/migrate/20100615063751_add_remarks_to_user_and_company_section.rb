class AddRemarksToUserAndCompanySection < ActiveRecord::Migration
  def self.up
    add_column    :users,            :remarks,     :string, :limit => 2048
    add_column    :company_sections, :remarks,     :string, :limit => 2048
    add_column    :companies,        :remarks,     :string, :limit => 2048
    change_column :clients,          :remarks,     :string, :limit => 2048
    change_column :categories,       :description, :string, :limit => 2048
    change_column :devices,          :description, :string, :limit => 2048
    change_column :distributors,     :remarks,     :string, :limit => 2048
    change_column :rentals,          :remarks,     :string, :limit => 2048
    change_column :rentals,       :offer_top_text, :string, :limit => 2048
    change_column :rentals,    :offer_bottom_text, :string, :limit => 2048
    change_column :sellings,         :remarks,     :string, :limit => 2048
    change_column :sellings,      :offer_top_text, :string, :limit => 2048
    change_column :sellings,   :offer_bottom_text, :string, :limit => 2048
    change_column :services,         :description, :string, :limit => 2048
  end

  def self.down
  end
end
