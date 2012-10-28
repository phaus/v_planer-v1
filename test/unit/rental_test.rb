require 'test_helper'

class RentalTest < ActiveSupport::TestCase

  def test_errors_are_collected_for_associated_models
    rental = Rental.new
    rental.items.build
    rental.items.build

    assert !rental.valid?
    assert !rental.items.first.valid?
    assert !rental.items.last.valid?
    assert_equal ["Begin can't be blank",
      "Client can't be blank",
      "Client discount i can't be blank",
      "Discount i can't be blank",
      "End can't be blank",
      "Items[0] (price i) can't be blank",
      "Items[0] (product) can't be blank",
      "Items[0] (unit price i) can't be blank",
      "Items[1] (price i) can't be blank",
      "Items[1] (product) can't be blank",
      "Items[1] (unit price i) can't be blank",
      "Price i can't be blank",
      "Product can't be blank",
      "Sender can't be blank",
      "Unit price i can't be blank",
      "User can't be blank"].sort, rental.errors.full_messages.sort
  end
end
