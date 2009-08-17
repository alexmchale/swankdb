require 'test_helper'

class SwankLogTest < ActiveSupport::TestCase
  test "the codes list is accurate" do
    assert_equal [], SwankLog.codes

    SwankLog.log 'DEF', :msg => 'first log'
    SwankLog.log 'DEF', :msg => 'second long'
    SwankLog.log 'ABC', :msg => 'third log'
    SwankLog.log 'XYZ', :msg => 'fourth log'

    assert_equal ['ABC', 'DEF', 'XYZ'], SwankLog.codes
  end

  test "can load and read complex objects" do
    complex = { :user => @bob, :array => [ 1, 2, [ 3, 4 ] ] }

    log1 = SwankLog.log('COMPLEX', complex)

    log = SwankLog.find(log1.id)

    assert log
    assert_equal 'COMPLEX', log.code
    assert_equal JSON.load(complex.to_json), JSON.load(log.message)
  end
end
