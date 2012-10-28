require File.dirname(__FILE__) + '/../test_helper'

class RentalPeriodsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:rental_periods)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_rental_period
    assert_difference('RentalPeriod.count') do
      post :create,
          :rental_period => {
            :client_id => clients(:clients_00001).id,
            :device_id => devices(:devices_00001).id,
            :count  => 1
          }
    end

    assert_redirected_to rental_period_path(assigns(:rental_period))
  end

  def test_should_show_rental_period
    get :show, :id => rental_periods(:rental_periods_00001).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => rental_periods(:rental_periods_00001).id
    assert_response :success
  end

  def test_should_update_rental_period
    put :update, :id => rental_periods(:rental_periods_00001).id, :rental_period => { }
    assert_redirected_to rental_period_path(assigns(:rental_period))
  end

  def test_should_destroy_rental_period
    assert_difference('RentalPeriod.count', -1) do
      delete :destroy, :id => rental_periods(:rental_periods_00001).id
    end

    assert_redirected_to rental_periods_path
  end
end
