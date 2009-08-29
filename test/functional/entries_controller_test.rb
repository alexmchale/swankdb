require 'test_helper'

class EntriesControllerTest < ActionController::TestCase
  def setup
  end

  test "getting a list of entries" do
    get :index

    @controller.set_current_user @bob

    get :index
    assert_response :success
  end

  test "creating and editing an entry with session based authentication" do
    get :index

    @controller.set_current_user @bob
    Entry.destroy_all

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

  test "destroying an entry with session based authentication" do
    get :index

    @controller.set_current_user @bob

    assert_not_nil Entry.find_by_id_and_user_id(@entry1.id, @bob.id)

    delete :destroy, :id => @entry1.id

    assert_nil Entry.find_by_id_and_user_id(@entry1.id, @bob.id)
  end

  test "destroying an entry with restful authentication" do
    get :index

    assert_not_nil Entry.find_by_id_and_user_id(@entry1.id, @bob.id)

    delete :destroy, :id => @entry1.id, :username => @bob.username, :password => '123456'

    assert_nil Entry.find_by_id_and_user_id(@entry1.id, @bob.id)
  end

  test "creating an entry with the api" do
    get :index

    @controller.set_current_user nil

    assert_difference('Entry.count') do
      post :create, :username => @bob.username,
                    :password => '123456',
                    :entry_content => 'My Content',
                    :json => true
      assert_response :success
    end

    response = JSON.parse(@response.body)

    assert response
    assert response['id']

    newentry = Entry.find_by_id(response['id'])

    assert newentry
    assert_equal @bob.id, newentry.user_id
    assert_equal 'My Content', newentry.content
    assert_equal '', newentry.tags
  end

  test "updating an existing entry with restful authentication" do
    assert_difference('Entry.count', 0) do
      put :update, :username => @alice.username,
                   :password => 'abcdef',
                   :id => @entry3.id,
                   :entry_content => '-Updated Content-',
                   :entry_tags => 'one',
                   :json => true
      assert_response :success
    end

    response = JSON.parse(@response.body)

    assert response
    assert response['id']

    entry = Entry.find_by_id(response['id'])

    assert entry
    assert_equal @entry3.id, entry.id
    assert_equal @alice.id, entry.user_id
    assert_equal '-Updated Content-', entry.content
    assert_equal ['one'], entry.tags_array
  end
end
