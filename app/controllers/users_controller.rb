class UsersController < ApplicationController
  before_filter :authenticate_user_account
  skip_filter :authenticate_user_account, :only => [ :new, :create, :login, :logout ]

  def new
    @user = User.new

    if session[:newuser]
      @user.username = session[:newuser][:username]
      @user.email = session[:newuser][:email]
    end
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
    elsif !check_password(password1, password2)
      redirect_to :action => :new
    else
      user = User.new
      user.username = username
      user.password = password1
      user.email = email
      user.save

      entry = Entry.new
      entry.user_id = user.id
      entry.content = <<WELCOME
## Welcome to SwankDB! ##
* SwankDB is a personal database for all your random bits of information.

## What makes SwankDB special ##
* SwankDB uses [Markdown](http://daringfireball.net/projects/markdown/),
  a readable, easy to use syntax for formatting your text.
* It sorts your information by when it was edited and by when it was created.
* Assign tags to your entries to help find them.

## Tips & Tricks ##
* FedEx and UPS tracking codes will automatically link to their tracking pages.
* Assign every tag you can think of to an entry to help you find it later.
WELCOME
      entry.tags = 'hello swankdb'
      entry.save

      user.reload

      session[:user] = user
      flash[:notice] = 'Your new user has been created.'
      redirect_to :controller => :entries, :action => :index
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    password1 = params[:password1].to_s
    password2 = params[:password2].to_s
    email = params[:email].to_s

    if check_password(password1, password2)
      flash[:notice] = 'Your profile settings have been updated.'
      @user.password = password1
      @user.email = email
      @user.save
    end

    redirect_to edit_user_path(@user)
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

  def invite
    unless params[:email].blank?
      email = Email.new
      email.user = session[:user]
      email.destination = params[:email].strip
      email.subject = "#{session[:user].username} invites you to try SwankDB"
      email.body = params[:message].strip + "\r\n\r\n#{session[:user].username} (#{session[:user].email})\r\n\r\n-- \r\n" + File.read('config/signature.txt')
      email.save
      flash[:notice] = 'Your invitation has been saved and will be sent shortly.  Thank you! :-)'
      redirect_to :controller => :users, :action => :invite
    end
  end

private

  def check_password(password1, password2)
    if password1 != password2
      flash[:error] = 'Those passwords do not match.'
      return false
    elsif password1.length < 6
      flash[:error] = 'The password must be at least six characters.'
      return false
    end

    return true
  end
end
