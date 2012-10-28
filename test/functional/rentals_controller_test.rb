require 'test_helper'

class RentalsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:rentals)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_rental
    assert_difference('Rental.count') do
      post :create,
          :rental => {
            :begin => 1.week.from_now,
            :end   => 2.weeks.from_now,
            :client_id  => clients(:clients_00002).id,
            :period_attributes => [
              {:device_id => devices(:devices_00094).id, :count => 1},
              {:device_id => devices(:devices_00095).id, :count => 2} ]
          }
    end

    assert_redirected_to rental_path(assigns(:rental))
  end

  def test_should_show_rental
    get :show, :id => rentals(:rentals_00001).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => rentals(:rentals_00001).id
    assert_response :success
  end

  def test_should_update_rental
    put :update,
        :id     => rentals(:rentals_00001).id,
        :rental => {}
    assert_redirected_to rental_path(assigns(:rental))
  end

  def test_should_destroy_rental
    assert_difference('Rental.count', -1) do
      delete :destroy, :id => rentals(:rentals_00001).id
    end

    assert_redirected_to rentals_path
  end
end
