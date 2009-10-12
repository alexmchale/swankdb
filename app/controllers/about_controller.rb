class AboutController < ApplicationController
  def index
    redirect_to(:controller => :entries, :action => :index) if current_user
  end
end
