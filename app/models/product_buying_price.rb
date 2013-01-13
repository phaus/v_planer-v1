class ProductBuyingPrice < ActiveRecord::Base

  belongs_to :product

  belongs_to :distributor

  validates_presence_of :distributor_id

end
