class AddOfferConfirmationTexts < ActiveRecord::Migration
  def self.up
    add_column :rentals, :offer_confirmation_top_text,     :string, :limit => 1000
    add_column :rentals, :offer_confirmation_bottom_text,  :string, :limit => 1000
    add_column :sellings, :offer_confirmation_top_text,    :string, :limit => 1000
    add_column :sellings, :offer_confirmation_bottom_text, :string, :limit => 1000
  end

  def self.down
    remove_column :rentals, :offer_confirmation_top_text
    remove_column :rentals, :offer_confirmation_bottom_text
    remove_column :sellings, :offer_confirmation_top_text
    remove_column :sellings, :offer_confirmation_bottom_text
  end
end
