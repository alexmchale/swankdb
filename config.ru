# Rack Dispatcher
ENV['RAILS_ENV'] ||= ENV['RACK_ENV']

# Require your environment file to bootstrap Rails
require Object::File.dirname(__FILE__) + '/config/environment'

# Serve CSS from tmp/public
use Rack::Static, :root => "tmp/public", :urls => %w( /stylesheets )

# Dispatch the request
run ActionController::Dispatcher.new

