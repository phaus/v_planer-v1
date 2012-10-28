class Expense < ActiveRecord::Base
  has_one :product,
      :dependent => :destroy

  validates_presence_of :name

#   monetary_value :unit_price
  def full_name
    self.name
  end

  def available_count(on=nil)
    1
  end
end
