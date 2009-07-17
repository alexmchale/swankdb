# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'digest/sha1'
require 'monkey'
require 'detector'
require 'email_verifier'

Rails::Initializer.run do |config|
  config.gem "sqlite3-ruby", :lib => "sqlite3"
  config.gem "andand"
  config.gem "bluecloth"
  config.gem "hpricot"
  config.gem "redgreen"
  config.gem "htmlentities"
  config.gem "cldwalker-hirb", :lib => "hirb"
  config.gem "alexmchale-gmail-client", :lib => "gmail"

  config.time_zone = 'UTC'
end

Sass::Plugin.options[:template_location] = File.join(RAILS_ROOT, 'app/sass')
Sass::Plugin.options[:css_location] = File.join(RAILS_ROOT, 'public/stylesheets')

Hirb.enable

