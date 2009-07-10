class UsersController < ApplicationController
  before_filter :authenticate_user_account
  skip_filter :authenticate_user_account, :only => [ :new, :create, :login, :logout ]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new

    if session[:newuser]
      @user.username = session[:newuser][:username]
      @user.email = session[:newuser][:email]
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    session[:newuser] = {
      :username => username = params[:username].to_s.downcase.gsub(/[^a-z0-9\.\-]/, ''),
      :password1 => password1 = params[:password1].to_s,
      :password2 => password2 = params[:password2].to_s,
      :email => email = params[:email].to_s
    }

    if User.find_by_username(username)
      flash[:error] = 'That username is not available.'
      redirect_to :action => :new
    elsif username.blank?
      flash[:error] = 'The username must not be blank.'
      redirect_to :action => :new
    elsif password1 != password2
      flash[:error] = 'Those passwords do not match.'
      redirect_to :action => :new
    elsif password1.length < 6
      flash[:error] = 'The password must be at least six characters.'
      redirect_to :action => :new
    else
      user = User.new
      user.username = username
      user.password = password1
      user.email = email
      user.save

      entry = Entry.new
      entry.user_id = user.id
      entry.content = 'Hello, and welcome to SwankDB!'
      entry.tags = 'hello swankdb'
      entry.save

      user.reload

      session[:user] = user
      flash[:notice] = 'Your new user has been created.'
      redirect_to :controller => :entries, :action => :index
    end
  end

  def update
    @user = User.find(params[:id])
    password1 = params[:password1].to_s
    password2 = params[:password2].to_s
    email = params[:email].to_s

    if password1 != password2
      flash[:error] = 'Those passwords do not match.'
    elsif password1.length < 6
      flash[:error] = 'The password must be at least six characters.'
    else
      flash[:notice] = 'Your profile settings have been updated.'
      @user.password = password1
      @user.email = email
      @user.save
    end

    redirect_to edit_user_path(@user)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def login
    unless params[:username].blank? || params[:password].blank?
      session[:user] = User.authenticate(params[:username], params[:password])

      if session[:user]
        flash[:notice] = "You have successfully logged in as #{session[:user].username}."
        redirect_to :controller => :entries, :action => :index
      else
        flash[:error] = "The username or password you entered is incorrect"
      end
    end
  end

  def logout
    session[:user] = nil
    redirect_to :action => :login
  end
end
