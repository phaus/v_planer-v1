require 'test_helper'

class ProcessItemsControllerTest < ActionController::TestCase
  setup do
    @process_item = process_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:process_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create process_item" do
    assert_difference('ProcessItem.count') do
      post :create, :process_item => @process_item.attributes
    end

    assert_redirected_to process_item_path(assigns(:process_item))
  end

  test "should show process_item" do
    get :show, :id => @process_item.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @process_item.to_param
    assert_response :success
  end

  test "should update process_item" do
    put :update, :id => @process_item.to_param, :process_item => @process_item.attributes
    assert_redirected_to process_item_path(assigns(:process_item))
  end

  test "should destroy process_item" do
    assert_difference('ProcessItem.count', -1) do
      delete :destroy, :id => @process_item.to_param
    end

    assert_redirected_to process_items_path
  end
end
