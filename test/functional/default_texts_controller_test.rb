require 'test_helper'

class DefaultTextsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:default_texts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create default_text" do
    assert_difference('DefaultText.count') do
      post :create, :default_text => { }
    end

    assert_redirected_to default_text_path(assigns(:default_text))
  end

  test "should show default_text" do
    get :show, :id => default_texts(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => default_texts(:one).to_param
    assert_response :success
  end

  test "should update default_text" do
    put :update, :id => default_texts(:one).to_param, :default_text => { }
    assert_redirected_to default_text_path(assigns(:default_text))
  end

  test "should destroy default_text" do
    assert_difference('DefaultText.count', -1) do
      delete :destroy, :id => default_texts(:one).to_param
    end

    assert_redirected_to default_texts_path
  end
end
