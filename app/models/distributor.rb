class Distributor < ActiveRecord::Base

  belongs_to :company
  belongs_to :address
  belongs_to :bank_account

  has_many :product_buying_prices,
      :dependent => :delete_all

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :bank_account

  validates_presence_of :company

end
