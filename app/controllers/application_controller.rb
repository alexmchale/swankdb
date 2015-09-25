# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout 'main'

  def set_current_user(user)
    @_user = if user.kind_of? User
               User.find_by(id: user.id)
             elsif user
               User.find_by(id: user)
             end

    session[:user_id] = @_user.andand.id
    @_user
  end

  def current_user
    @_user ||= ActiveCode.find_by(code: params[:frob]).andand.user
    @_user ||= User.authenticate(params[:username], params[:password])
    @_user ||= User.find_by(id: session[:user_id])
  end

  def current_user_id
    current_user.andand.id
  end

private

  def authenticate_user_account
    redirect_to(:controller => :users, :action => :login) unless current_user
  end

  def render_data(data)
    if params.has_key? :xml
      render :xml => data
    else
      render :json => data
    end
  end
end
