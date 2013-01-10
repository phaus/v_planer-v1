class RentalPeriod < ActiveRecord::Base
  belongs_to :process,
      :class_name  => 'Rental',
      :foreign_key => 'rental_id'
  belongs_to :product

  has_many :unavailabilities,
      :dependent => :destroy
  has_many :product_stock_entries,
      :through => :unavailabilities

  scope :between, lambda {|from, to|
    joins('rentals ON rental_id=rentals.id').where(['rentals.begin < ? AND rentals.end > ?', to, from]).order('rentals.id').asc
  }

  after_save :persist_calculated_fields

  collect_errors_from :product, :unavailabilities

  validates_presence_of :unit_price_i,
      :price_i,
      :product,
      :process

  accepts_nested_attributes_for :product

  monetary_value :price,
      :unit_price

  def duration
    if self.from_date == self.to_date
      1.0
    else
      (self.to_date - self.from_date) / 1.day
    end
  end

  def billed_duration
    self.process.billed_duration
  end

  def overlaps?(other)
    (self.from_date..self.to_date).overlaps?(other.from_date..other.to_date)
  end

  def includes?(date)
    (self.from_date.to_date..self.to_date.to_date).include?(date.to_date)
  end

  def unit
    'd'
  end

  def unit_price
    up = self.read_attribute(:unit_price_i)
    up ? up / 100.0 : self.product.unit_price
  end

  def price
    pi = self.read_attribute(:price_i)
    factor = self.billed_duration
    pi ? (pi / 100.0) : (self.unit_price * self.count * factor)
  end

  def count=(new_count)
    @count = new_count.to_i
    self[:count] = new_count.to_i
  end

  def count
    @count || self[:count] || self.unavailabilities.count
  end

  def from_date
    self.rental.begin
  end

  def to_date
    self.rental.end
  end

  # for compatibility
  def rental
    self.process
  end

  # for compatibility
  def rental=(new_rental)
    self.process = new_rental
  end

  protected

  def validate_availability
    if self.product.article.respond_to? :stock_entries and not @count.nil?
      self.class.transaction do
        self.unavailabilities.destroy_all
        stock_entries = self.product.article.stock_entries.available_between(self.from_date, self.to_date).all(:limit => @count)
        self.errors.add :count, "Im gewählten Zeitraum sind nur #{stock_entries.size} Artikel vom Typ #{self.product.full_name} verfügbar!" unless stock_entries.size == @count
        rollback_db_transaction
      end
    end
  end

  def persist_calculated_fields
    unless @count.nil?
      self.write_attribute :count, @count
      if self.product.article.respond_to? :stock_entries
        self.class.transaction do
          self.unavailabilities.destroy_all
          raise 'could not delete existing unavailabilities!' unless self.unavailabilities.count == 0
          stock_entries = self.product.article.stock_entries.available_between(self.from_date, self.to_date).all(:limit => @count)
          stock_entries.each do |pse|
            self.unavailabilities.create!(:product_stock_entry => pse, :from_date => self.from_date, :to_date => self.to_date)
          end
        end
      end
    end
  end

end
