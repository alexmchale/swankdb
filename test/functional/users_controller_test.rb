require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "new user form exists" do
    # Verify the form exists correctly.
    get :new
    assert_response :success
    assert_select 'form#new_user'
    assert_select 'input#username'
    assert_select 'input#password1'
    assert_select 'input#password2'
    assert_select 'input#email'
  end

  test "creating a user account" do
    # Verify that no user exists with the name testuser1 or email test@user.com
    assert_nil User.find_by_username('testuser')
    assert_nil User.find_by_email('test@user.com')

    # Create the new user.
    post :create, :username => 'testuser', :password1 => 'abc123', :password2 => 'abc123', :email => 'test@user.com'
    assert_response :redirect
    assert_redirected_to :controller => :entries, :action => :index

    # Verify the new user exists.
    new_user = User.authenticate('testuser', 'abc123')
    assert new_user
    assert_equal 'test@user.com', new_user.email
  end

  test "creating a user with invalid fields" do
    # Delete all users before starting.
    User.delete_all

    # Post to the account create page with no username.
    post :create, :username => '', :password1 => 'abc123', :password2 => 'abc123', :email => 'test@user.com'
    assert_response :redirect
    assert_redirected_to :action => :new

    # Post to the account create page with no password.
    post :create, :username => 'testuser', :password1 => '', :password2 => '', :email => 'test@user.com'
    assert_response :redirect
    assert_redirected_to :action => :new

    # Post to the account create page with mismatching passwords.
    post :create, :username => 'testuser', :password1 => 'abc123', :password2 => 'xyz123', :email => 'test@user.com'
    assert_response :redirect
    assert_redirected_to :action => :new

    # Make sure no users were created in this process.
    assert_equal 0, User.count
  end

  test "account settings page exists" do
    # Act like we're logged in as bob.
    session[:user] = @bob

    get :edit, :id => @bob.id
    assert_select "form#edit_user_#{@bob.id}"
    assert_select 'input#password1'
    assert_select 'input#password2'
    assert_select 'input#email'
  end

  test "logging into an account" do
    # Set a known password.
    @bob.password = 'abcdef'
    @bob.save

    # Test the login page.
    get :login
    assert_select 'form#login'
    assert_select 'input#username'
    assert_select 'input#password'

    # Post a valid login.
    post :login, :username => @bob.username, :password => 'abcdef'
    assert_redirected_to :controller => :entries, :action => :index

    # Make sure we successfully logged in.
    assert session[:user]
    assert_equal @bob.id, session[:user].id
  end

  test "an invalid login attempt" do
    post :login, :username => 'dummy', :password => 'badpass'
    assert_redirected_to :action => :login
    assert_equal "The username or password you entered is incorrect.", flash[:error]
    assert_nil session[:user]

    post :login, :username => '', :password => 'badpass'
    assert_redirected_to :action => :login
    assert_equal "The username or password you entered is incorrect.", flash[:error]
    assert_nil session[:user]

    post :login, :username => 'dummy', :password => ''
    assert_redirected_to :action => :login
    assert_equal "The username or password you entered is incorrect.", flash[:error]
    assert_nil session[:user]

    post :login
    assert_redirected_to :action => :login
    assert_equal "The username or password you entered is incorrect.", flash[:error]
    assert_nil session[:user]
  end

  test "setting a new user password" do
    # Act like we're logged in as bob.
    session[:user] = @bob

    # Set bob to have a known password.
    @bob.password = 'abc123'
    @bob.save

    # Make sure the password/email we're going to set doesn't work already.
    assert_nil User.authenticate(@bob.username, 'xyz123')
    assert_nil User.find_by_email('bobbyjoe@user.com')

    # Use the account settings page to set a new password.
    post :update, :id => @bob.id, :password1 => 'xyz123', :password2 => 'xyz123', :email => @bob.email
    assert_response :redirect
    assert_redirected_to :action => :edit

    # Assert the password we just set now works.
    assert User.authenticate(@bob.username, 'xyz123')

    # Use the account settings page to set a new email.
    post :update, :id => @bob.id, :password1 => '', :password2 => '', :email => 'bobbyjoe@user.com'
    assert_response :redirect
    assert_redirected_to :action => :edit

    # Assert the new email is correct, and the password hasn't changed.
    assert User.authenticate(@bob.username, 'xyz123')
    assert User.find_by_email('bobbyjoe@user.com')
  end

  test "resetting a user's password" do
    # Test accessing the password reset page.
    get :reset_password
    assert_response :success
    assert_select 'input#username'
    assert_select 'input#email'

    # Verify that bob has no reset code, and no reset email in process.
    assert_nil @bob.active_code('reset-password')
    assert_nil Email.find(:first, :conditions => { :user_id => @bob.id })

    # Post to the password reset page for bob.
    post :reset_password, :username => @bob.username
    assert_equal "We have sent a password reset request to the email address on file.", flash[:notice]

    # Verify that bob now has a reset code.
    assert @bob.reload
    code = @bob.active_code('reset-password')
    assert_not_nil code

    # Verify that bob now has a reset email in process.
    email = Email.find(:first, :conditions => { :user_id => @bob.id })
    assert_not_nil email
    assert_equal 'Password reset requested on SwankDB', email.subject
    assert_equal @bob.email, email.destination
    assert_match code.code, email.body

    # Test accessing the password reset page emailed to bob.
    get :reset_password, :reset_code => code.code
    assert_response :success
    assert_select 'input#password1'
    assert_select 'input#password2'

    # Verify that 123456 is not bob's password.
    assert_nil User.authenticate(@bob.username, '123456')

    # Post a new password for bob using the password reset page.
    post :reset_password, :reset_code => code.code, :password1 => '123456', :password2 => '123456'
    assert_equal 'Your password has been updated.', flash[:notice]

    # Verify that 123456 is now bob's password.
    authenticated = User.authenticate(@bob.username, '123456')
    assert_not_nil authenticated
    assert_equal @bob.id, authenticated.id

    # Verify that bob no longer has a reset code.
    assert @bob.reload
    assert_nil @bob.active_code('reset-code')
  end
end
