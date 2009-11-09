# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout 'main'

#  rescue_from Exception do |ex|
#    if RAILS_ENV == 'production'
#      ErrorMailer.deliver_snapshot(ex, ex.backtrace, session, params, request.env)
#      flash[:error] = "I'm sorry, an error has occurred in SwankDB.  A report has been filed."
#      redirect_to '/'
#    else
#      raise ex
#    end
#  end

  def set_current_user(user)
    @_user = if user.kind_of? User
               User.find_by_id(user.id)
             elsif user
               User.find_by_id(user)
             end

    session[:user_id] = @_user.andand.id
    @_user
  end

  def current_user
    @_user ||= ActiveCode.find_by_code(params[:frob]).andand.user
    @_user ||= User.authenticate(params[:username], params[:password])
    @_user ||= User.find_by_id(session[:user_id])
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
