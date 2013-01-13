class Distributor < ActiveRecord::Base
  include Concerns::Addressable

  belongs_to :company

  has_many :product_buying_prices,
      :dependent => :delete_all

  validates_presence_of :company

end
