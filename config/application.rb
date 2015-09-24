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
    ActiveRecord::Base.include_root_in_json = false

    ActionController::Base.config.relative_url_root = ''

  end

end
