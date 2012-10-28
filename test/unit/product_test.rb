require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test 'product price can be unset by passing nil or empty string to price setters' do
    product = products(:products_00170)
    product.selling_price = 10
    product.rental_price  = 10
    assert product.is_rentable?, 'product should be rentable'
    assert product.is_sellable?, 'product should be sellable'

    product.article.attributes = {:rental_price => '', :selling_price => nil}
    assert_nil product.rental_price
    assert_nil product.selling_price
    assert !product.is_rentable?, 'product should not be rentable'
    assert !product.is_sellable?, 'product should not be sellable'

    product.article.attributes = {:rental_price => '23,4', :selling_price => '123.4'}
    assert product.is_rentable?, 'product should be rentable'
    assert product.is_sellable?, 'product should be sellable'
  end

end
