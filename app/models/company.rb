class Company < ActiveRecord::Base

  belongs_to :admin,
      :class_name => 'User'

  has_many :sections,
      :class_name => 'CompanySection'

  belongs_to :main_section,
      :class_name => 'CompanySection'

  has_many :clients

  has_many :invoices

  has_many :distributors

  accepts_nested_attributes_for :admin
  accepts_nested_attributes_for :main_section

  validates_presence_of :name,
      :main_section,
      :admin

  delegate :phone,
      :fax,
      :mobile,
      :street,
      :postalcode,
      :locality,
      :country,
      :email,
      :homepage,
      :bank_name,
      :bank_account,
      :bank_account_owner,
      :bank_blz,
      :bank_bic,
      :bank_iban,
      :bank_details_valid?,
      :sender_address_block,
      :sender_address_window,
      :vat_id,
      :tax_id,
      :to => :main_section

  after_save :autoset_company_section

  after_create :update_company

  def rentals
    Rental.for_company(self)
  end

  def sellings
    Selling.for_company(self)
  end

  def products
    Product.for_company(self)
  end

  def categories
    Category.for_company(self)
  end

  def users
    User.for_company(self)
  end

  def commercial_processes
    CommercialProcess.for_company(self)
  end

  def non_main_sections
    self.sections - [self.main_section]
  end

  def date_format
    :de
  end

  protected

  def autoset_company_section
    unless self.main_section.company_id == self.id
      self.main_section.update_attribute :company_id, self.id
    end
  end

  def update_company
    self.main_section.update_attribute :company, self
  end
end
