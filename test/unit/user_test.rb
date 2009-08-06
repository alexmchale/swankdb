require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "temporary user flag" do
    assert User.create.temporary
    assert User.create(:username => '', :password => '').temporary
    assert User.create(:username => '', :password => '123456').temporary
    assert !User.create(:username => 'mcman1', :password => '').temporary
    assert !User.create(:username => 'mcman2', :password => '123456').temporary
  end

  test "all user objects are destroyed when the user is" do
    alice_id = @alice.id

    assert_difference '@alice.active_codes.count', 12 do
      # Add frobs to alice.
      12.times {@alice.new_active_code('frob')}
    end

    assert_difference '@alice.entries.count', 12 do
      # Add twelve entries to alice.
      12.times {Entry.create(:user => @alice)}
    end

    @alice.reload

    # Destroy alice and make sure none of the stuff we created still exists.
    assert_not_equal 0, ActiveCode.count(:conditions => { :user_id => alice_id })
    assert_not_equal 0, Entry.count(:conditions => { :user_id => alice_id })
    @alice.destroy
    assert_nil ActiveCode.find(:first, :conditions => { :user_id => alice_id })
    assert_equal 0, ActiveCode.count(:conditions => { :user_id => alice_id })
    assert_equal 0, Entry.count(:conditions => { :user_id => alice_id })
  end
end
