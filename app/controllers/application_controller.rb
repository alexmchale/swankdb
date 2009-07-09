# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout 'main'

protected

  def current_user
    session[:user]
  end

  def current_user_id
    session[:user].andand.id
  end

private

  def authenticate_user_account
    redirect_to(:controller => :users, :action => :login) unless session[:user]
  end

  def render_data(data)
    if params.has_key? :xml
      render :xml => data
    else
      render :json => data
    end
  end
end
