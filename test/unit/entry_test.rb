require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  fixtures :users
  self.use_instantiated_fixtures = true

  test "a user's all_tags gets set when an entry is saved" do
    e = Entry.new :user => @bob, :tags => 'xyz abc jkl'
    assert e.save
    assert @bob.reload
    assert_equal 'abc jkl xyz', @bob.all_tags

    e = Entry.new :user => @bob, :tags => 'foo bar abc baz'
    assert e.save
    assert @bob.reload
    assert_equal 'abc bar baz foo jkl xyz', @bob.all_tags

    e = Entry.new :user => @bob
    assert e.save
    assert @bob.reload
    assert_equal 'abc bar baz foo jkl xyz'.split, @bob.tags
  end

  test "a user's all_tags gets reset when an entry is destroyed" do
    e = Entry.new :user => @bob, :tags => '5 6 7 8 9'
    assert e.save
    assert @bob.reload
    assert_equal '5 6 7 8 9', @bob.all_tags

    e = Entry.new :user => @bob, :tags => '1 2 3 4 5 6 7'
    assert e.save
    assert @bob.reload
    assert_equal '1 2 3 4 5 6 7 8 9', @bob.all_tags

    assert e.destroy
    assert @bob.reload
    assert_equal '5 6 7 8 9', @bob.all_tags
  end

  test "split_tags should split on whitespace and sort" do
    result = Entry.split_tags('5 2 3 1 4')
    expect = [ '1', '2', '3', '4', '5' ]
    assert_equal expect, result

    result = Entry.split_tags('     xyz             123   abc            ')
    expect = [ '123', 'abc', 'xyz' ]
    assert_equal expect, result

    result = Entry.split_tags('   who?        you-do       what.else              expectation!yields@foo      ')
    expect = [ 'expectation!yields@foo', 'what.else', 'who?', 'you-do' ]
    assert_equal expect, result

    result = Entry.split_tags("   \n   xyz   \r\n    abc    foobar   ")
    expect = [ 'abc', 'foobar', 'xyz' ]
    assert_equal expect, result
  end

  test "pretty_tags should take a yucky tags string and turn it into a new one" do
    result = Entry.pretty_tags('5 2 3 1 4')
    expect = '1 2 3 4 5'
    assert_equal expect, result

    result = Entry.pretty_tags('     xyz             123   abc            ')
    expect = '123 abc xyz'
    assert_equal expect, result

    result = Entry.pretty_tags('   who?        you-do       what.else              expectation!yields@foo      ')
    expect = 'expectation!yields@foo what.else who? you-do'
    assert_equal expect, result

    result = Entry.pretty_tags("   \n   xyz   \r\n    abc    foobar   ")
    expect = 'abc foobar xyz'
    assert_equal expect, result
  end

  test "tags should automatically fix up when saving an entry" do
    e = Entry.new(:tags => "   \n   xyz   \r\n    abc    foobar   ", :user => @bob)
    assert e.save
    assert e.reload
    assert_equal ' abc foobar xyz ', e.tags

    e = Entry.new(:user => @bob)
    assert e.save
    assert e.reload
    assert_equal '', e.tags
  end

  test "content should have links correctly embedded when calling linkup" do
    e = Entry.new(:content => '1ZX799330100198551', :user => @bob)

    ups = '1ZX799330100198551'
    ups_linked = '<a href="http://wwwapps.ups.com/WebTracking/processInputRequest?sort_by=status&tracknums_displayed=1&TypeOfInquiryNumber=T&loc=en_US&InquiryNumber1=1ZX799330100198551&track.x=0&track.y=0" class="urlified">1ZX799330100198551</a>'
    assert_equal ups_linked, Entry.new(:content => ups, :user => @bob).linkup

    fedex = '732812804843'
    fedex_linked = '<a href="http://www.fedex.com/Tracking?language=english&cntry_code=us&tracknumbers=732812804843" class="urlified">732812804843</a>'
    assert_equal fedex_linked, Entry.new(:content => fedex, :user => @bob).linkup
  end
end
