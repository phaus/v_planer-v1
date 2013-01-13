class Service < ActiveRecord::Base
  has_one :product,
      :dependent => :destroy

  validates_presence_of :name,
      :unit_price

  def unit
    u = read_attribute(:unit)
    u.blank? ? 'Std' : u
  end

  def rental_price
    self.unit_price
  end

  def full_name
    self.name
  end

  def availability(from, to=nil)
    from_date = from.to_date
    to_date   = to ? to.to_date : from_date.tomorrow
    availabilities = []
    from_date.upto(to_date) do |date|
      availabilities << [date, 1]
    end
    availabilities
  end

  def available_count(on=nil)
    1
  end

end
