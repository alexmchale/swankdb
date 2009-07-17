require 'test_helper'

class ActiveCodeTest < ActiveSupport::TestCase
  fixtures :users
  self.use_instantiated_fixtures = true

  test "new user codes are generated correctly" do
    code1 = @bob.new_active_code('password-reset')
    assert_not_nil code1
    assert_equal 'password-reset', code1.section
    assert_equal @bob.id, code1.user_id
    assert_not_nil @bob.active_code('password-reset')

    code2 = @bob.new_active_code('confirm-account')
    assert_not_nil code2

    assert_equal code1.code, @bob.active_code('password-reset').code
  end

  test "codes older than 2 days aren't returned" do
    code = @bob.new_active_code('test')

    assert_not_nil code

    code.created_at = Time.now - 2.days + 10.seconds
    code.save

    code = @bob.active_code('test')

    assert_not_nil code

    code.created_at = Time.now - 2.days - 10.seconds
    code.save

    code = @bob.active_code('test')

    assert_nil code
  end
end
