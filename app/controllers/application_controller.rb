# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :authenticate_user_account

  layout 'main'

protected

  def current_user_id
    session[:user].andand.id
  end

private

  def authenticate_user_account
    redirect_to(:controller => :users, :action => :login) unless session[:user]
  end
end
