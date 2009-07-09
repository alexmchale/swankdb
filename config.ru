# Rack Dispatcher

# Require your environment file to bootstrap Rails
require Object::File.dirname(__FILE__) + '/config/environment'

# Dispatch the request
run ActionController::Dispatcher.new
