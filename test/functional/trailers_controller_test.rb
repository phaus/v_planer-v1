require File.dirname(__FILE__) + '/../test_helper'

class TrailersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:trailers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_trailer
    assert_difference('Trailer.count') do
      post :create, :trailer => { }
    end

    assert_redirected_to trailer_path(assigns(:trailer))
  end

  def test_should_show_trailer
    get :show, :id => trailers(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => trailers(:one).id
    assert_response :success
  end

  def test_should_update_trailer
    put :update, :id => trailers(:one).id, :trailer => { }
    assert_redirected_to trailer_path(assigns(:trailer))
  end

  def test_should_destroy_trailer
    assert_difference('Trailer.count', -1) do
      delete :destroy, :id => trailers(:one).id
    end

    assert_redirected_to trailers_path
  end
end
