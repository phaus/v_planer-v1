# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130126214850) do

  create_table "addresses", :force => true do |t|
    t.string   "street"
    t.string   "postalcode"
    t.string   "locality"
    t.string   "country"
    t.string   "phone"
    t.string   "fax"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_accounts", :force => true do |t|
    t.string   "bank_name"
    t.string   "registrar_name"
    t.string   "blz"
    t.string   "number"
    t.string   "iban"
    t.string   "bic"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "calendar_dates", :force => true do |t|
    t.date "value"
  end

  add_index "calendar_dates", ["value"], :name => "value"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "description",        :limit => 2048
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_section_id"
  end

  add_index "categories", ["company_section_id"], :name => "company_section_id"

  create_table "categories_products", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "product_id"
  end

  create_table "clients", :force => true do |t|
    t.string   "forename"
    t.string   "surname"
    t.string   "title"
    t.string   "password"
    t.string   "company"
    t.string   "phone"
    t.string   "email"
    t.date     "birthday"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "client_no"
    t.string   "fax"
    t.string   "mobile"
    t.string   "homepage"
    t.integer  "payment_goal",      :limit => 8,    :default => 7
    t.integer  "discount",          :limit => 8
    t.integer  "contact_person_id", :limit => 8
    t.integer  "company_id"
    t.integer  "owner_id"
    t.string   "remarks",           :limit => 2048
    t.integer  "address_id"
    t.integer  "bank_account_id"
  end

  add_index "clients", ["company_id"], :name => "company_id"
  add_index "clients", ["contact_person_id"], :name => "contact_person_id"
  add_index "clients", ["owner_id"], :name => "owner_id"

  create_table "commercial_processes", :force => true do |t|
    t.integer  "client_id",                      :limit => 8
    t.integer  "sender_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "workflow_state"
    t.string   "process_no"
    t.string   "title",                                                                         :default => ""
    t.string   "remarks",                        :limit => 2048
    t.string   "offer_top_text",                 :limit => 2048
    t.string   "offer_bottom_text",              :limit => 2048
    t.string   "offer_confirmation_top_text",    :limit => 1000
    t.string   "offer_confirmation_bottom_text", :limit => 1000
    t.decimal  "discount",                                       :precision => 10, :scale => 2
    t.decimal  "client_discount",                                :precision => 10, :scale => 2
    t.integer  "implementation_id"
    t.string   "implementation_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.integer  "admin_id"
    t.integer  "main_section_id",                                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rental_process_no_format",                  :default => "M-%id"
    t.string   "selling_process_no_format",                 :default => "K-%id"
    t.string   "remarks",                   :limit => 2048
    t.string   "tax_id"
    t.string   "vat_id"
  end

  create_table "company_sections", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.string   "bank_name",                             :default => ""
    t.string   "bank_account",                          :default => ""
    t.string   "bank_account_owner",    :limit => 200
    t.string   "bank_blz",                              :default => ""
    t.string   "bank_bic",              :limit => 50
    t.string   "bank_iban",             :limit => 50
    t.string   "sender_address_block"
    t.string   "sender_address_window", :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "phone",                 :limit => 30
    t.string   "fax",                   :limit => 30
    t.string   "mobile",                :limit => 30
    t.string   "homepage"
    t.string   "vat_id"
    t.string   "street"
    t.string   "postalcode"
    t.string   "locality"
    t.string   "country"
    t.integer  "address_id"
    t.integer  "bank_account_id"
    t.string   "remarks",               :limit => 2048
    t.string   "tax_id"
  end

  add_index "company_sections", ["company_id"], :name => "company_id"

  create_table "default_texts", :force => true do |t|
    t.string   "name",               :limit => 100
    t.string   "value",              :limit => 2000
    t.integer  "company_section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_availabilities", :id => false, :force => true do |t|
    t.date    "value"
    t.integer "device_id",                             :null => false
    t.integer "count",     :limit => 8, :default => 0, :null => false
  end

  create_table "device_availabilities_table", :id => false, :force => true do |t|
    t.date    "value"
    t.integer "device_id",                             :null => false
    t.integer "count",     :limit => 8, :default => 0, :null => false
  end

  create_table "devices", :force => true do |t|
    t.string   "name"
    t.string   "description",     :limit => 2048
    t.integer  "width",           :limit => 8
    t.integer  "height",          :limit => 8
    t.integer  "length",          :limit => 8
    t.integer  "weight",          :limit => 8
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "available_count", :limit => 8
    t.string   "manufacturer"
    t.integer  "buying_price_i",  :limit => 8
    t.integer  "selling_price_i", :limit => 8
    t.float    "vat_rate",        :limit => 255
    t.string   "unit"
    t.integer  "rental_price_i",  :limit => 8
    t.boolean  "is_rentable",                                                    :default => false
    t.boolean  "is_sellable",                                                    :default => false
    t.decimal  "buying_price",                    :precision => 10, :scale => 2
    t.decimal  "selling_price",                   :precision => 10, :scale => 2
    t.decimal  "rental_price",                    :precision => 10, :scale => 2
  end

  create_table "distributors", :force => true do |t|
    t.integer  "company_id"
    t.string   "company_name"
    t.string   "contact_person"
    t.string   "title"
    t.string   "password"
    t.string   "company"
    t.string   "phone"
    t.string   "email"
    t.string   "mobile"
    t.string   "fax"
    t.string   "remarks",         :limit => 2048
    t.string   "client_no"
    t.string   "homepage"
    t.string   "discount",                        :default => "0.0"
    t.string   "street"
    t.string   "postalcode"
    t.string   "locality"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "address_id"
    t.integer  "bank_account_id"
  end

  add_index "distributors", ["company_id"], :name => "company_id"

  create_table "expense_items", :force => true do |t|
    t.integer  "process_id"
    t.string   "process_type"
    t.integer  "client_id"
    t.integer  "product_id"
    t.float    "count1"
    t.float    "factor1"
    t.float    "count2"
    t.float    "factor2"
    t.float    "count3"
    t.float    "factor3"
    t.integer  "const1"
    t.integer  "price_i"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",        :precision => 10, :scale => 2
  end

  create_table "expenses", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.float    "factor1",      :default => 1.0
    t.string   "unit1"
    t.string   "factor1_name"
    t.float    "factor2",      :default => 1.0
    t.string   "unit2"
    t.string   "factor2_name"
    t.float    "factor3",      :default => 1.0
    t.string   "unit3"
    t.string   "factor3_name"
    t.float    "const1",       :default => 0.0
    t.string   "const1_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_items", :force => true do |t|
    t.integer  "process_item_id"
    t.string   "process_item_type"
    t.integer  "invoice_id"
    t.integer  "price_i"
    t.string   "remarks",           :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",                            :precision => 10, :scale => 2
  end

  create_table "invoices", :force => true do |t|
    t.date     "date"
    t.integer  "client_id"
    t.integer  "sender_id"
    t.integer  "user_id"
    t.integer  "process_id"
    t.string   "process_type", :limit => 50
    t.integer  "price_i"
    t.string   "remarks",      :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "invoice_no"
    t.decimal  "price",                        :precision => 10, :scale => 2
  end

  create_table "process_items", :force => true do |t|
    t.integer  "commercial_process_id"
    t.integer  "product_id"
    t.string   "name"
    t.string   "remarks"
    t.decimal  "quantity",              :precision => 10, :scale => 2
    t.string   "unit"
    t.integer  "cost_calculation_id"
    t.string   "cost_calculation_type"
    t.decimal  "vat_percentage",        :precision => 4,  :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_buying_prices", :force => true do |t|
    t.integer  "product_id"
    t.integer  "distributor_id"
    t.integer  "price_i"
    t.string   "article_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",          :precision => 10, :scale => 2
  end

  create_table "product_stock_entries", :force => true do |t|
    t.integer  "serial",                     :default => 1,  :null => false
    t.integer  "device_id",                                  :null => false
    t.string   "remarks",    :limit => 1024, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_stock_entries", ["device_id"], :name => "device_id"

  create_table "products", :force => true do |t|
    t.integer  "company_section_id"
    t.string   "code"
    t.string   "article_type"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delta",              :null => false
    t.string   "name"
    t.string   "description"
    t.string   "long_description"
    t.string   "internal_remarks"
  end

  add_index "products", ["article_type", "article_id"], :name => "article_type"
  add_index "products", ["article_type", "article_id"], :name => "article_type_2"
  add_index "products", ["company_section_id"], :name => "company_section_id"
  add_index "products", ["company_section_id"], :name => "company_section_id_2"

  create_table "rental_periods", :force => true do |t|
    t.datetime "from_date"
    t.datetime "to_date"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rental_id",    :limit => 8
    t.float    "count"
    t.integer  "product_id"
    t.integer  "unit_price_i"
    t.integer  "price_i"
    t.decimal  "unit_price",                :precision => 10, :scale => 2
    t.decimal  "price",                     :precision => 10, :scale => 2
  end

  add_index "rental_periods", ["product_id"], :name => "product_id"
  add_index "rental_periods", ["rental_id"], :name => "rental_id"

  create_table "rental_processes", :force => true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "delivery_date"
    t.datetime "return_date"
    t.decimal  "billed_duration", :precision => 10, :scale => 0
    t.integer  "process_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "rentals", :force => true do |t|
    t.datetime "begin"
    t.datetime "end"
    t.integer  "client_id",                      :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sender_id"
    t.integer  "discount_i"
    t.integer  "client_discount_i"
    t.integer  "usage_duration"
    t.float    "billed_duration"
    t.integer  "user_id"
    t.string   "workflow_state"
    t.string   "process_no"
    t.string   "offer_top_text",                 :limit => 2048
    t.string   "offer_bottom_text",              :limit => 2048
    t.string   "remarks",                        :limit => 2048
    t.string   "title",                                                                         :default => ""
    t.string   "offer_confirmation_top_text",    :limit => 1000
    t.string   "offer_confirmation_bottom_text", :limit => 1000
    t.decimal  "discount",                                       :precision => 10, :scale => 2
    t.decimal  "client_discount",                                :precision => 10, :scale => 2
  end

  add_index "rentals", ["begin"], :name => "begin"
  add_index "rentals", ["client_id"], :name => "client_id"
  add_index "rentals", ["end"], :name => "end"
  add_index "rentals", ["sender_id"], :name => "sender_id"
  add_index "rentals", ["user_id"], :name => "user_id"

  create_table "selling_items", :force => true do |t|
    t.string   "comments"
    t.float    "count"
    t.integer  "product_id"
    t.integer  "process_id"
    t.integer  "price_i"
    t.integer  "unit_price_i"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",        :precision => 10, :scale => 2
    t.decimal  "unit_price",   :precision => 10, :scale => 2
  end

  create_table "sellings", :force => true do |t|
    t.integer  "client_id"
    t.integer  "user_id"
    t.integer  "discount_i",                                                                    :default => 0
    t.integer  "price_i"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_discount_i",                                                             :default => 0
    t.integer  "sender_id"
    t.string   "workflow_state"
    t.string   "process_no"
    t.string   "offer_top_text",                 :limit => 2048
    t.string   "offer_bottom_text",              :limit => 2048
    t.string   "remarks",                        :limit => 2048
    t.string   "title"
    t.string   "offer_confirmation_top_text",    :limit => 1000
    t.string   "offer_confirmation_bottom_text", :limit => 1000
    t.decimal  "discount",                                       :precision => 10, :scale => 2
    t.decimal  "price",                                          :precision => 10, :scale => 2
    t.decimal  "client_discount",                                :precision => 10, :scale => 2
  end

  create_table "service_items", :force => true do |t|
    t.integer  "process_id"
    t.string   "process_type"
    t.integer  "client_id"
    t.integer  "product_id"
    t.integer  "count"
    t.float    "duration"
    t.text     "comments"
    t.integer  "unit_price_i"
    t.integer  "price_i"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_price",   :precision => 10, :scale => 2
    t.decimal  "price",        :precision => 10, :scale => 2
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.string   "description",  :limit => 2048
    t.integer  "unit_price_i",                                                :default => 0
    t.string   "unit",                                                        :default => "Std."
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_price",                   :precision => 10, :scale => 2
  end

  create_table "stock_entry_availabilities", :id => false, :force => true do |t|
    t.integer "id",        :default => 0, :null => false
    t.date    "value"
    t.integer "device_id",                :null => false
  end

  create_table "trivial_cost_calculations", :force => true do |t|
    t.decimal  "unit_price", :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  create_table "unavailabilities", :force => true do |t|
    t.integer  "rental_period_id"
    t.integer  "product_stock_entry_id"
    t.datetime "from_date"
    t.datetime "to_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unavailabilities", ["product_stock_entry_id"], :name => "product_stock_entry_id"
  add_index "unavailabilities", ["rental_period_id"], :name => "rental_period_id"

  create_table "users", :force => true do |t|
    t.string   "forename"
    t.string   "surname"
    t.string   "login"
    t.string   "password_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "crypted_password",                    :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "persistence_token",                   :default => "", :null => false
    t.string   "single_access_token",                 :default => "", :null => false
    t.integer  "login_count",                         :default => 0,  :null => false
    t.integer  "failed_login_count",                  :default => 0,  :null => false
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.integer  "company_section_id",                                  :null => false
    t.string   "email",                                               :null => false
    t.integer  "bank_account_id"
    t.integer  "address_id"
    t.string   "remarks",             :limit => 2048
  end

  add_index "users", ["company_section_id"], :name => "company_section_id"

  create_table "v_planer_audition_change_events", :force => true do |t|
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "action"
    t.string   "message"
    t.integer  "triggered_by_id"
    t.string   "triggered_by_name"
    t.integer  "on_behalf_of_id"
    t.string   "on_behalf_of_name"
    t.integer  "authenticated_user_id"
    t.string   "authenticated_user_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "v_planer_rental_rental_processes", :force => true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "delivery_date"
    t.datetime "return_date"
    t.decimal  "billed_duration", :precision => 10, :scale => 0
    t.integer  "process_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
