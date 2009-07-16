class AboutController < ApplicationController
  def index
    if session[:user]
      redirect_to :controller => :entries, :action => :index
    end
  end
end
