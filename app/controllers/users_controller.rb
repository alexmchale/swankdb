class UsersController < ApplicationController
  before_filter :authenticate_user_account
  skip_filter :authenticate_user_account, :only => [ :new, :create, :login, :logout, :reset_password, :instant ]

  def new
    set_current_user nil

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

    if !ip_eligible_for_new_user?
      redirect_to :action => :new
    elsif User.find_by_username(username)
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
      session.delete :newuser

      user = User.new
      user.username = username
      user.password = password1
      user.email = email
      user.save

      user.add_default_entry

      SwankLog.log('USER-CREATED', { :user => user, :source => request.remote_ip }.to_yaml)

      set_current_user user
      flash[:notice] = "Your new account has been created.  Thanks for joining SwankDB!"
      redirect_to :controller => :entries, :action => :index
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    username = params[:username].to_s
    password1 = params[:password1].to_s
    password2 = params[:password2].to_s
    email = params[:email].to_s

    if current_user.temporary
      if check_username(username) && check_password(password1, password2)
        flash[:notice] = "Your new account has been created.  Thanks for joining SwankDB!"

        @user.username = username
        @user.password = password1
        @user.email = email
        @user.save

        return redirect_to :controller => :entries, :action => :index
      end
    else
      if (password1.blank? && password2.blank?) || check_password(password1, password2)
        flash[:notice] = 'Your account settings have been updated.'

        @user.password = password1 unless password1.blank?
        @user.email = email
        @user.save

        return redirect_to :controller => :entries, :action => :index
      end
    end

    redirect_to edit_user_path(current_user)
  end

  def login
    if request.post?
      set_current_user User.authenticate(params[:username], params[:password])

      if current_user
        # flash[:notice] = "You have successfully logged in as #{current_user.username}."
        redirect_to :controller => :entries, :action => :index
      else
        flash[:error] = "The username or password you entered is incorrect."
        redirect_to :controller => :users, :action => :login
      end
    elsif params[:frob] && current_user
      set_current_user current_user
      redirect_to :controller => :entries, :action => :index
    end
  end

  def logout
    set_current_user nil
    redirect_to :action => :login
  end

  def invite
    if request.post?
      if params[:email].andand.email?
        email = Email.new
        email.user = current_user
        email.destination = params[:email].strip
        email.subject = "#{current_user.username} invites you to try SwankDB"
        email.body = params[:message].strip + "\r\n\r\n#{current_user.username} (#{current_user.email})\r\n\r\n-- \r\n" + File.read('config/signature.txt')
        email.save

        SwankLog.log 'INVITATION-CREATED', email.to_yaml

        flash[:notice] = 'Your invitation has been saved and will be sent shortly.  Thank you! :-)'
        redirect_to :controller => :users, :action => :invite
      else
        flash[:error] = 'Please enter a valid email address.'
      end
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
        set_current_user @user
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
        @user.active_code('reset-password').andand.destroy
        reset_code = @user.new_active_code('reset-password', Time.now + 2.days).code

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

  def instant
    if ip_eligible_for_new_user?
      set_current_user User.create
      SwankLog.log('USER-CREATED', { :user => current_user, :source => request.remote_ip }.to_yaml)
      current_user.andand.add_default_entry
      flash[:error] = "You're using a cookie-based, temporary account.  Click " +
                      '<a href="/users/edit">my account</a>' +
                      " to set up your account permanantly."
      redirect_to :controller => :entries, :action => :index
    else
      redirect_to :action => :new
    end
  end

  def check_username(username)
    not
    if username.blank?
      flash[:error] = 'Please enter a username for your new account.'
    elsif User.find_by_username(username)
      flash[:error] = "I'm sorry, that username is already in use."
    end
  end

  def check_password(password1, password2)
    if password1 != password2
      flash[:error] = 'Those passwords do not match.'
      return false
    elsif password1.length < 3
      flash[:error] = 'Your password must be at least three characters.'
      return false
    end

    return true
  end

  def ip_eligible_for_new_user?
    conditions = [ 'message LIKE ? AND updated_at>?', "%#{request.remote_ip}%", Time.now - 2.minutes ]

    SwankLog.find(:all, :conditions => conditions, :order => 'updated_at DESC').each do |log|
      if (parsed = log.parsed).kind_of? Hash
        if parsed[:source] == request.remote_ip
          flash[:error] = 'A user has recently been created by your ip address.'
          return false
        end
      end
    end

    true
  end
end
