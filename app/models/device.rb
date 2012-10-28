class Device < ActiveRecord::Base
  has_one :product,
      :as        => 'article',
      :dependent => :destroy

  has_many :stock_entries,
      :class_name => 'ProductStockEntry',
      :dependent  => :destroy

  has_many :unavailabilities,
      :class_name => 'DeviceAvailability'

  validates_presence_of :name

  monetary_value :buying_price,
      :rental_price,
      :selling_price

  after_save :synchronize_stock_entries

  collect_errors_from :unavailabilities, :stock_entries

  def size
    "#{self.width}mm x #{self.height}mm x #{self.length}mm"
  end

  def full_name
    if self.manufacturer.blank?
      self.name
    else
      "#{self.manufacturer} #{self.name}"
    end
  end

  def available_count(on=nil)
    if on.nil?
      @available_count ||= self.stock_entries.count
    else
      availability(on).first.last
    end
  end

  def availability(from, to=nil)
    from_date = from.to_date
    to_date   = to ? to.to_date : from_date.tomorrow
    availabilities   = []
    unavailabilities = self.unavailabilities.between(from_date, to_date).all.inject({}){|m,e| m[e.date.to_s] = e.count; m}
    from_date.upto(to_date) do |date|
      available_count = self.available_count - (unavailabilities[date.to_s] || 0)
      availabilities << [date, available_count]
    end
    availabilities
  end

  def unit
    u = read_attribute(:unit)
    u.blank? ? 'Stk' : u
  end

  def unit_price
    self.rental_price
  end

  def available_count=(count)
    count = count.to_i
    current_count = self.stock_entries.size
    return if current_count == count
    if current_count < count
      @add_new_stock_entries = count
    else
      raise 'Verkleinern des Bestandes funktioniert noch nicht!'
    end
  end

  def gross_rental_price
    self.rental_price ? self.rental_price * (1.0 + self.vat_rate / 100.0) : nil
  end

  def gross_rental_price=(new_price)
#      price = new_price.blank? ? nil : (new_price.to_s.gsub(',', '.').to_f * 100)
#      self.write_attribute :rental_price, 100.0 * price / self.vat_rate
  end

  def gross_selling_price
    self.selling_price ? self.selling_price * (1.0 + self.vat_rate / 100.0) : nil
  end

  def vat_rate
    self.read_attribute(:vat_rate) || 19.0
  end

  def gross_selling_price=(new_price)
  end

  protected

  def synchronize_stock_entries
    if @add_new_stock_entries
      (self.stock_entries.size + 1).upto(@add_new_stock_entries) do |i|
        self.stock_entries.create :serial => i
      end
    end
  end

end
