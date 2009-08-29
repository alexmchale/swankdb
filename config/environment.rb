# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'digest/sha1'
require 'monkey'
require 'detector'
require 'email_verifier'
require 'smtp_tls'

Rails::Initializer.run do |config|
  config.gem "sqlite3-ruby", :lib => "sqlite3"
  config.gem "andand"
  config.gem "rdiscount"
  config.gem "htmlentities"
  config.gem "cldwalker-hirb", :lib => "hirb"
  config.gem "alexmchale-gmail-client", :lib => "gmail"
  config.gem "icalendar"
  config.gem "fastercsv"
  config.gem "crafterm-comma", :lib => "comma"

  config.time_zone = 'UTC'
end

Sass::Plugin.options[:template_location] = File.join(RAILS_ROOT, 'app/sass')
Sass::Plugin.options[:css_location] = File.join(RAILS_ROOT, 'public/stylesheets')

Hirb.enable rescue nil # Try to load Hirb if it's available.

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => "587",
  :domain => "gmail.com",
  :authentication => :plain,
  :user_name => "swank@swankdb.com",
  :password => "bt60M32FWfJHOX7O1yaY"
}

ActiveRecord::Base.include_root_in_json = false

