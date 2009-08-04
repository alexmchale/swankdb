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

  test "can load and read complex objects" do
    complex = { :user => @bob, :array => [ 1, 2, [ 3, 4 ] ] }

    SwankLog.log 'COMPLEX', complex

    log = SwankLog.last
    assert log
    assert_equal 'COMPLEX', log.code
    assert_equal complex, log.parsed
  end
end
