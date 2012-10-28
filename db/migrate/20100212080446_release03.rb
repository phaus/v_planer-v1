class Release03 < ActiveRecord::Migration
  def self.up
    add_column :rental_periods, :product_id,    :integer
    add_column :rental_periods, :unit_price_i,  :integer, :default => nil, :null => true
    add_column :rental_periods, :price_i,       :integer, :default => nil, :null => true

    rename_column :clients, :owner_id, :contact_person_id
    add_column :clients, :company_id,         :integer
    add_column :clients, :owner_id,           :integer
    add_column :clients, :remarks,            :string

    add_column :categories, :company_section_id, :integer

    add_column :rentals, :billed_duration,   :float, :default => nil, :null => true
    add_column :rentals, :user_id,           :integer

    create_table :users do |t|
      t.string :forename
      t.string :surname
      t.string :username
      t.string :password_hash
      t.string :email
      t.integer :company_section_id

      t.timestamps
    end

    create_table :companies do |t|
      t.string  :name
      t.integer :admin_id
      t.integer :main_section_id, :integer
      t.string  :email
      t.string  :phone
      t.string  :fax
      t.string  :mobile
      t.string  :street
      t.string  :postalcode
      t.string  :locality
      t.string  :country

      t.timestamps
    end
    create_table :services do |t|
      t.string  :name
      t.text    :description,    :default => ''
      t.integer :owner_id
      t.integer :unit_price_i,   :default => 0
      t.string  :unit,           :default => 'Std.'

      t.timestamps
    end
    create_table :company_sections do |t|
      t.string  :name
      t.integer :company_id
      t.string  :bank_name,                    :default => ''
      t.string  :bank_account,                 :default => ''
      t.string  :bank_blz,                     :default => ''
      t.string  :sender_address_block
      t.timestamps
    end
    create_table :products do |t|
      t.integer :company_section_id
      t.string  :code
      t.string  :article_type
      t.integer :article_id

      t.timestamps
    end

    create_table :categories_products, :primary_key => false do |t|
      t.integer :category_id
      t.integer :product_id
    end
    create_table :distributors do |t|
      t.integer :company_id
      t.string :company_name
      t.string :contact_person
      t.string :title
      t.string :password
      t.string :company
      t.string :phone
      t.string :email
      t.string :mobile
      t.string :fax
      t.string :remarks
      t.string :client_no
      t.string :homepage
      t.string :discount, :default => 0.0
      t.string :street
      t.string :postalcode
      t.string :locality
      t.string :country

      t.timestamps
    end
    rename_column :users, :username, :login

    add_column :users, :crypted_password,    :string, :null => false, :default => ''  # optional, see below
    add_column :users, :password_salt,       :string, :null => false, :default => ''  # optional, but highly recommended
    add_column :users, :persistence_token,   :string, :null => false, :default => ''  # required
    add_column :users, :single_access_token, :string, :null => false, :default => ''  # optional, see Authlogic::Session::Params
    add_column :users, :perishable_token,    :string, :null => false, :default => ''  # optional, see Authlogic::Session::Perishability

    # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
    add_column :users, :login_count,        :integer,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
    add_column :users, :failed_login_count, :integer,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
    add_column :users, :last_request_at,    :datetime                                # optional, see Authlogic::Session::MagicColumns
    add_column :users, :current_login_at,   :datetime                                # optional, see Authlogic::Session::MagicColumns
    add_column :users, :last_login_at,      :datetime                                # optional, see Authlogic::Session::MagicColumns
    add_column :users, :current_login_ip,   :string                                  # optional, see Authlogic::Session::MagicColumns
    add_column :users, :last_login_ip,      :string                                  # optional, see Authlogic::Session::MagicColumns

  end

  def self.down
    rename_column :users, :login, :username

    remove_column :users, :crypted_password
    remove_column :users, :password_salt
    remove_column :users, :persistence_token
    remove_column :users, :single_access_token
    remove_column :users, :perishable_token
    remove_column :users, :login_count
    remove_column :users, :failed_login_count
    remove_column :users, :last_request_at
    remove_column :users, :current_login_at
    remove_column :users, :last_login_at
    remove_column :users, :current_login_ip
    remove_column :users, :last_login_ip

    remove_column :rental, :user_id
    remove_column :users, :email
    remove_column :rentals, :billed_duration

    remove_column :rental_periods, :unit_price_i
    remove_column :rental_periods, :price_i
    drop_table :distributors
    remove_column :clients, :remarks
    remove_column :rentals, :billing_duration
    remove_column :categories, :company_section_id
    remove_column :clients, :company_id
    remove_column :clients, :contact_person_id
    change_column :rentals, :usage_duration, :integer
    remove_column :rental_periods, :product_id
    drop_table :products
    drop_table :categories_products
    remove_column :users, :company_section_id
    drop_table :company_sections
    drop_table :services
    drop_table :companies
    remove_column :rentals, :client_discount_i
    remove_column :rentals, :usage_duration
    remove_column :rentals, :discount
    remove_column :clients, :owner_id
    remove_column :rentals, :sender_id
    remove_column :devices, :rental_price
    drop_table :users
    remove_column :devices, :manufacturer
    remove_column :devices, :buying_price
    remove_column :devices, :selling_price
    remove_column :devices, :vat_rate
    remove_column :devices, :unit
    remove_column :devices, :owner_id

    remove_column :clients, :fax
    remove_column :clients, :mobile
    remove_column :clients, :homepage
    remove_column :clients, :payment_goal
    remove_column :clients, :discount
    remove_column :devices, :available_count
    remove_column :rental_periods, :count
    drop_table :rentals
    remove_column :rental_periods, :rental_id
  end
end
