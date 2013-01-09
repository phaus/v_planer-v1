class Client < ActiveRecord::Base
  has_many :rentals
  has_many :sellings
  belongs_to :address
  belongs_to :bank_account
  belongs_to :company
  belongs_to :contact_person,
      :class_name => 'User'

  validate :presence_of_company_name_or_full_name
  validates_presence_of :client_no,
      :contact_person_id,
      :company,
      :address

  scope :matching, lambda {|q|
    where([%q(CONCAT(clients.forename, ' ', clients.surname) REGEXP ? OR clients.remarks REGEXP ? OR clients.company REGEXP ? OR clients.client_no REGEXP ?), *[q]*4])
  }

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :bank_account

  def processes
    self.rentals + self.sellings
  end

  def full_name
    str = "#{self.title} #{self.forename} #{self.surname}"
    str.blank? ? "Fa. #{self.company_name}" : str
  end

  def company_name=(name)
    write_attribute :company, name
  end

  def company_name
    read_attribute :company
  end

  def discount
     self.read_attribute(:discount) || 0.0
  end

  def presence_of_company_name_or_full_name
    if self.company_name.blank? and self.full_name.blank?
      errors.add 'Firmenname und Personenname dürfen nicht beide leer sein.'
    end
  end

  def discount
    self.read_attribute(:discount) || 0.0
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
