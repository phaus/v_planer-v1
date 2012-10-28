# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

if Gem::VERSION >= "1.3.6" 
  module Rails
    class GemDependency
      def requirement
        r = super
        (r == Gem::Requirement.default) ? nil : r
      end
    end
  end
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  config.plugins = [:tabular_navigation, :all]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :key => '_planer_session',
    :secret      => 'eabddc46cd37d3759c40ed477142e9f881f67b0e327227866f2c790c14a37fb3e95d82bccad4dbedaf2fc3bf797ef0516cf42a6ef63b786c0cde4fce65c0984f'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
#  config.gem 'rake', '0.8.7'
#  config.gem 'vpim'
#  config.gem 'fastercsv'
#  config.gem 'webrat'
#  config.gem 'authlogic'
#  config.gem 'workflow'
#  config.gem 'sass'
end

PDF_LETTER_COMPANY       = 'Digital Media Productions Witten'
PDF_LETTER_SENDER_WINDOW = 'DMPW - Digital Media Productions Witten, Waldstr. 52, D-58453 Witten'

APP_SETTINGS = {}
APP_SETTINGS[:enable_client_csv_import]                            = false
APP_SETTINGS[:enable_device_csv_import]                            = false
APP_SETTINGS[:allow_non_admin_users_to_edit_client_contact_person] = false
APP_SETTINGS[:allow_non_admin_users_to_edit_product_owner]         = false
APP_SETTINGS[:allow_non_admin_users_to_edit_category_owner]        = false
APP_SETTINGS[:allow_non_admin_users_to_edit_client_no]             = false
APP_SETTINGS[:number_of_displayed_processes_in_account_view]       = 5
APP_SETTINGS[:show_article_comments_in_invoice]                    = false

