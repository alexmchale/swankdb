class UsersController < ApplicationController
  before_filter :authenticate_user_account
  skip_filter :authenticate_user_account, :only => [ :new, :create, :login, :logout, :reset_password ]

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
      :email => email = params[:email].to_s.strip
    }

    if User.find_by_username(username)
      flash[:error] = 'That username is not available.'
      redirect_to :action => :new
    elsif User.find_by_email(email)
      flash[:error] = 'An account with that email address already exists.'
      redirect_to :action => :new
    elsif !email.email?
      flash[:error] = 'Please enter a valid email address.'
      redirect_to :action => :new
    elsif username.blank?
      flash[:error] = 'Please enter a username.'
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
      entry.content = File.read('config/welcome.txt')
      entry.tags = 'hello swankdb'
      entry.save

      user.reload

      SwankLog.log 'USER-CREATED', user.to_yaml

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

    if (password1.blank? && password2.blank?) || check_password(password1, password2)
      flash[:notice] = 'Your profile settings have been updated.'
      @user.password = password1 unless password1.blank?
      @user.email = email
      @user.save
    end

    redirect_to edit_user_path(@user)
  end

  def login
    unless params[:username].blank? || params[:password].blank?
      session[:user] = User.authenticate(params[:username], params[:password])

      if session[:user]
        # flash[:notice] = "You have successfully logged in as #{session[:user].username}."
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

      SwankLog.log 'INVITATION-CREATED', email.to_yaml

      flash[:notice] = 'Your invitation has been saved and will be sent shortly.  Thank you! :-)'
      redirect_to :controller => :users, :action => :invite
    end
  end

  def reset_password
    username = params[:username]
    email = params[:email]

    password1 = params[:password1]
    password2 = params[:password2]

    @code = ActiveCode.find(:first, :conditions => { :code => params[:reset_code] })
    @user = @code.andand.user

    if @code && @user && password1 && password2
      # User has presented a valid reset code and entered new passwords.

      if check_password(password1, password2)
        @user.password = password1
        @user.save

        @code.destroy
        @user.reload

        flash[:notice] = 'Your password has been updated.'
        session[:user] = @user
        redirect_to :controller => :entries, :action => :index
      else
        redirect_to request.request_uri
      end
    elsif @code && @user
      # User has hit us from the emailed link.

      render 'confirmed_set_password'
    elsif username || email
      # User has filled out the "request a new password" form.
      # Verify that we have a user that exists for one of the two provided credentials.
      # Create a new reset code for this user and email it to them.

      @user = User.find_by_username(username)
      @user ||= User.find_by_email(email)

      if @user
        reset_code = @user.new_active_code('reset-password').code

        email = Email.new
        email.user = @user
        email.destination = @user.email
        email.subject = 'Password reset requested on SwankDB'
        email.body = "Please click this link to reset your password:\r\n" +
                     "http://#{request.env['HTTP_HOST']}/users/reset_password?reset_code=#{reset_code}"
        email.save

        flash[:notice] = "We have sent a password reset request to the email address on file."

        redirect_to '/'
      else
        flash[:error] = "We can't find a user with those credentials.  Please try again."

        redirect_to :action => :reset_password
      end
    else
      # User has hit us from any other source.
      # Send a page to request a new password based on your email address or username.

      render 'request_new_password'
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
