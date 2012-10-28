require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < ActiveSupport::TestCase

  def test_client_without_attributes_is_invalid
    client = Client.new
    assert_equal false, client.valid?, 'client should be invalid'
    assert client.errors.invalid? :contact_person_id
    assert client.errors.invalid? :client_no
    assert client.errors.invalid? :company
  end

  def test_create_minimal_client
    client = Client.new \
        :contact_person => users(:tweber),
        :company   => companies(:dmpw),
        :client_no => '0815',
        :forename  => 'Foo',
        :surname   => 'Bar'
    assert client.save, client.errors.full_messages.join(', ')
  end

  def test_company_has_many_clients
    company = companies(:dmpw)
    assert_equal [32, 35, 36, 37, 38, 39, 40, 56, 63, 67, 68, 70, 71, 72, 75, 76, 77, 79].sort, company.client_ids.sort
  end

end
