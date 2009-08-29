require 'test_helper'

class MonkeyTest < ActiveSupport::TestCase
  test "generating html nonbreak spaces from a fixnum" do
    assert_equal '', -1.spaces
    assert_equal '', 0.spaces
    assert_equal '&nbsp;', 1.spaces
    assert_equal '&nbsp;&nbsp;', 2.spaces
    assert_equal '&nbsp;&nbsp;&nbsp;', 3.spaces
  end

  test "stripping html from a string" do
    assert_equal "helloworld", "hello<br>world".striphtml
  end
end
