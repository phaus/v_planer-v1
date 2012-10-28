class Release04 < ActiveRecord::Migration
  def self.up
    add_column :rentals,  :workflow_state, :string                     rescue nil
    add_column :sellings, :workflow_state, :string                     rescue nil
    add_column :sellings, :client_discount_i, :integer, :default => 0  rescue nil
    add_column :sellings, :sender_id, :integer                         rescue nil
    add_column :users,    :bank_account_id, :integer                   rescue nil
    add_column :users,    :address_id, :integer                        rescue nil
    add_column :clients,  :address_id, :integer                        rescue nil
    add_column :company_sections, :address_id, :integer                rescue nil
    add_column :company_sections, :bank_account_id, :integer           rescue nil

    create_table :invoices do |t|
      t.date :date
      t.integer :client_id
      t.integer :sender_id
      t.integer :user_id
      t.integer :process_id
      t.string  :process_type, :limit => 50
      t.integer :price_i
      t.string :remarks, :limit => 1000

      t.timestamps
    end rescue nil
    create_table :invoice_items do |t|
      t.integer :process_item_id
      t.string :process_item_type
      t.integer :invoice_id
      t.integer :price_i
      t.string :remarks, :limit => 500

      t.timestamps
    end rescue nil
    create_table :product_stock_entries do |t|
      t.integer :serial,                    :null => false, :default => 1
      t.integer :device_id,                 :null => false
      t.string  :remarks,   :limit => 1024, :null => false, :default => ''

      t.timestamps
    end rescue nil
    create_table :unavailabilities do |t|
      t.integer :rental_period_id
      t.integer :product_stock_entry_id
      t.datetime :from_date
      t.datetime :to_date

      t.timestamps
    end rescue nil
    create_table :selling_items do |t|
      t.string  :comments
      t.float   :count
      t.integer :product_id
      t.integer :process_id
      t.integer :price_i
      t.integer :unit_price_i

      t.timestamps
    end rescue nil
    create_table :product_buying_prices do |t|
      t.integer :product_id
      t.integer :distributor_id
      t.integer :price_i
      t.string :article_no

      t.timestamps
    end rescue nil
    create_table :bank_accounts do |t|
      t.string :bank_name
      t.string :registrar_name
      t.string :blz
      t.string :number
      t.string :iban
      t.string :bic

      t.timestamps
    end rescue nil
    create_table :addresses do |t|
      t.string :street
      t.string :postalcode
      t.string :locality
      t.string :country
      t.string :phone
      t.string :fax
      t.string :mobile

      t.timestamps
    end rescue nil
    create_table :calendar_dates do |t|
      t.date :value
    end rescue nil
    create_table :sellings do |t|
      t.integer :client_id
      t.integer :user_id
      t.integer :discount_i
      t.integer :price_i

      t.timestamps
    end rescue nil

    ActiveRecord.connection.execute %(CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `device_availabilities` AS select `calendar_dates`.`value` AS `value`,`product_stock_entries`.`device_id` AS `device_id`,count(distinct `unavailabilities`.`id`) AS `count` from (`calendar_dates` join (`unavailabilities` join `product_stock_entries` on((`product_stock_entries`.`id` = `unavailabilities`.`product_stock_entry_id`))) on((`calendar_dates`.`value` between `unavailabilities`.`from_date` and `unavailabilities`.`to_date`))) group by `calendar_dates`.`id`,`product_stock_entries`.`device_id`;)
  end

  def self.down
  end
end
