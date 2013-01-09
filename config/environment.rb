# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
VPlaner::Application.initialize!

Rails.logger = Logger.new "#{Rails.root}/log/#{Rails.env}.log"
