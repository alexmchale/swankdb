require 'test_helper'

class EntriesControllerTest < ActionController::TestCase
  def setup
    @controller.set_current_user @bob
  end

  test "entry creating and editing" do
    get :new
    assert_select 'textarea#entry_content'
    assert_select 'input#entry_tags'

    post :create, :entry_content => 'This is a test entry.', :entry_tags => 'one two three'

    @bob.reload

    assert_equal 'one three two', @bob.all_tags

    entry = Entry.find(:first, :conditions => { :user_id => @bob.id }, :order => 'created_at DESC')

    assert_not_nil entry
    assert_equal 'This is a test entry.', entry.content
    assert_equal ' one three two ', entry.tags

    get :edit, :id => entry.id
    assert_select 'textarea#entry_content'
    assert_select 'input#entry_tags'

    post :update, :id => entry.id, :entry_content => 'New Text', :entry_tags => '9 8 7'

    entry.reload

    assert_equal entry.content, 'New Text'
    assert_equal entry.tags, ' 7 8 9 '
  end

  test "destroying an entry" do
    entry = Entry.new
    entry.user = @bob
    entry.save
    id = entry.id

    assert_not_nil id
    assert_not_nil Entry.find(id)

    delete :destroy, :id => id

    assert_redirected_to :controller => :entries, :action => :index
    assert_nil Entry.find_by_id(id)
  end
end
