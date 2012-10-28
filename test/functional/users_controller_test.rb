require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_user
    assert_difference('User.count') do
      post :create,
          :user => {
              :forename => 'foo',
              :surname  => 'bar',
              :login => 'foobar',
              :password => 'test',
              :password_confirmation => 'test'
          }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  def test_should_show_user
    get :show, :id => users(:users_00001).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => users(:users_00001).id
    assert_response :success
  end

  def test_should_update_user
    put :update,
        :id   => users(:users_00001).id,
        :user => {
          :forename => 'qux'
        }
    assert_redirected_to user_path(assigns(:user))
  end

  def test_should_destroy_user
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:users_00001).id
    end

    assert_redirected_to users_path
  end
end
