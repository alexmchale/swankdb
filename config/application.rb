require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module SwankDB

  class Application < Rails::Application

    require 'digest/sha1'
    require 'monkey'
    require 'detector'
    require 'email_verifier'

    Sass::Plugin.options[:template_location] = File.join(Rails.root, 'app/sass')
    Sass::Plugin.options[:css_location] = File.join(Rails.root, 'public/stylesheets')

    Hirb.enable rescue nil # Try to load Hirb if it's available.

    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = {
      :address => "smtp.gmail.com",
      :port => "587",
      :tls => true,
      :domain => "gmail.com",
      :authentication => :plain,
      :user_name => "swank@swankdb.com",
      :password => "bt60M32FWfJHOX7O1yaY"
    }

    ActiveRecord::Base.include_root_in_json = false

  end

end
