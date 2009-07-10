require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "a user's all_tags gets set when an entry is saved" do
    u = User.new :username => 'testman1'
    assert u.save

    e = Entry.new :user => u, :tags => 'xyz abc jkl'
    assert e.save
    assert u.reload
    assert_equal 'abc jkl xyz', u.all_tags

    e = Entry.new :user => u, :tags => 'foo bar abc baz'
    assert e.save
    assert u.reload
    assert_equal 'abc bar baz foo jkl xyz', u.all_tags

    e = Entry.new :user => u
    assert e.save
    assert u.reload
    assert_equal 'abc bar baz foo jkl xyz'.split, u.tags
  end

  test "a user's all_tags gets reset when an entry is destroyed" do
    u = User.new :username => 'testman2'
    assert u.save

    e = Entry.new :user => u, :tags => '5 6 7 8 9'
    assert e.save
    assert u.reload
    assert_equal '5 6 7 8 9', u.all_tags

    e = Entry.new :user => u, :tags => '1 2 3 4 5 6 7'
    assert e.save
    assert u.reload
    assert_equal '1 2 3 4 5 6 7 8 9', u.all_tags

    assert e.destroy
    assert u.reload
    assert_equal '5 6 7 8 9', u.all_tags
  end
end
