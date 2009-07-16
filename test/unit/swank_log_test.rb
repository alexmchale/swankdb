require 'test_helper'

class SwankLogTest < ActiveSupport::TestCase
  test "the codes list is accurate" do
    assert_equal [], SwankLog.codes

    SwankLog.log 'DEF', 'first log'
    SwankLog.log 'DEF', 'second long'
    SwankLog.log 'ABC', 'third log'
    SwankLog.log 'XYZ', 'fourth log'

    assert_equal ['ABC', 'DEF', 'XYZ'], SwankLog.codes
  end
end
