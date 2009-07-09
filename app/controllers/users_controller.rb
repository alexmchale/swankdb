class UsersController < ApplicationController
  before_filter :authenticate_user_account
  skip_filter :authenticate_user_account, :only => [ :new, :create, :login, :logout ]

  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    username = params[:username].to_s.downcase
    password1 = params[:password1].to_s
    password2 = params[:password2].to_s
    email = params[:email].to_s

    if User.find_by_username(username)
      flash[:notice] = 'That username is not available.'
      redirect_to :action => :new
    elsif username.blank?
      flash[:notice] = 'The username must not be blank.'
      redirect_to :action => :new
    elsif password1 != password2
      flash[:notice] = 'Those passwords do not match.'
      redirect_to :action => :new
    elsif password1.length < 6
      flash[:notice] = 'The password must be at least six characters.'
      redirect_to :action => :new
    else
      user = User.new
      user.username = username
      user.password = password1
      user.email = email
      user.save

      session[:user] = user
      flash[:notice] = 'Your new user has been created.'
      redirect_to :controller => :entries, :action => :index
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
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
