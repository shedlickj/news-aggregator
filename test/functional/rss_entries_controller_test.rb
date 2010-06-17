require 'test_helper'

class RssEntriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rss_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rss_entry" do
    assert_difference('RssEntry.count') do
      post :create, :rss_entry => { }
    end

    assert_redirected_to rss_entry_path(assigns(:rss_entry))
  end

  test "should show rss_entry" do
    get :show, :id => rss_entries(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => rss_entries(:one).to_param
    assert_response :success
  end

  test "should update rss_entry" do
    put :update, :id => rss_entries(:one).to_param, :rss_entry => { }
    assert_redirected_to rss_entry_path(assigns(:rss_entry))
  end

  test "should destroy rss_entry" do
    assert_difference('RssEntry.count', -1) do
      delete :destroy, :id => rss_entries(:one).to_param
    end

    assert_redirected_to rss_entries_path
  end
end
