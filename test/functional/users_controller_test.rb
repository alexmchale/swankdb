require 'test_helper'

class UsersControllerTest < ActionController::TestCase
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
  end
end
