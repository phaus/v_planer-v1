class Client < ActiveRecord::Base
  include Conforming::ModelExtensions
  include Concerns::Addressable

  has_many :rentals
  has_many :sellings

  belongs_to :company
  belongs_to :contact_person,
      :class_name => 'User'

  validates_presence_of :client_no,
      :contact_person_id,
      :company,
      :address

  scope :matching, lambda {|q|
    where [%q(CONCAT(clients.forename, ' ', clients.surname, ' ', clients.remarks, ' ', clients.company, ' ', clients.client_no) REGEXP ?), q]
  }

  def processes
    self.rentals + self.sellings
  end

  def company_name=(name)
    write_attribute :company, name
  end

  def company_name
    read_attribute :company
  end

  default_value_for :discount do
    0.0
  end

  def self.next_client_no
    curr = maximum(:client_no)
    if curr =~ /^([^\d]*)(\d+)([^\d]*)$/
      "#{$1}#{$2.to_i.succ}#{$3}"
    else
      (curr||0).succ
    end
  end

end
