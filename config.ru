# Rack Dispatcher
ENV['RAILS_ENV'] ||= ENV['RACK_ENV']

# Require your environment file to bootstrap Rails
require ::File.expand_path('../config/environment', __FILE__)

# Serve CSS from tmp/public
use Rack::Static, :root => "tmp/public", :urls => %w( /stylesheets )

# Dispatch the request
run Rails.application
