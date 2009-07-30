require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "temporary user flag" do
    assert User.create.temporary
    assert User.create(:username => '', :password => '').temporary
    assert User.create(:username => '', :password => '123456').temporary
    assert !User.create(:username => 'mcman1', :password => '').temporary
    assert !User.create(:username => 'mcman2', :password => '123456').temporary
  end
end
