class Product < ActiveRecord::Base
  include Concerns::CompanyAsset

  has_and_belongs_to_many :categories

  belongs_to :article,
      :polymorphic => true,
      :dependent   => :destroy

  has_many :rental_periods

  has_many :buying_prices,
      :class_name => 'ProductBuyingPrice',
      :dependent => :destroy

  has_many :distributors,
      :through => :buying_prices

  accepts_nested_attributes_for :buying_prices,
      :allow_destroy => true,
      :reject_if => lambda {|bp| bp[:distributor_id].blank? }

  delegate :full_name,
      :unit,
      :vat_rate,
      :available_count,
      :rental_price,
      :selling_price,
      :to => :article

  scope :matching, lambda {|str| where([%q(CONCAT(products.name, '-', products.code, '-', products.description) REGEXP ?), str])}

  scope :available_between, lambda {|from_date, to_date|
    where [%q(products.article_id NOT IN (SELECT product_stock_entries.device_id FROM product_stock_entries
              JOIN unavailabilities ON unavailabilities.product_stock_entry_id = product_stock_entries.id
              JOIN rental_periods   ON rental_periods.id = unavailabilities.rental_period_id
              JOIN rentals          ON rentals.id = rental_periods.rental_id
              WHERE (rentals.end NOT BETWEEN ? AND ?) AND (rentals.begin  NOT BETWEEN ? AND ?))), from_date, to_date, from_date, to_date]
  }

  scope :service, where(:article_type => 'Service')

  scope :device, where(:article_type => 'Device')

  validates_presence_of :article,
      :company_section

  collects_errors_from :article, :distributors, :buying_prices

  def method_missing(method_name, *attrs)
    if self.article and self.article.respond_to? method_name
      self.article.send method_name, *attrs
    else
      super
    end
  end

  def is_rentable?
    self.article.respond_to? :is_rentable? and self.article.is_rentable?
  end

  def is_sellable?
    self.article.respond_to? :is_sellable? and self.article.is_sellable?
  end

  def service?
    self.article.is_a? Service
  end

  def to_json(options={})
    super :include => :article
  end

  def availability(from, to)
    self.article.respond_to?(:availability) ? self.article.availability(from, to) : 1
  end

  def article_type=(type)
    raise 'article is already initialized' unless self.article.nil?
    case type
    when 'Device'
      self.article = Device.new
    when 'Service'
      self.article = Service.new
    else
      raise "unknown article_type: #{type}"
    end
  end

  def article_type
    self.article ? self.article.class.to_s : nil
  end

  def device_attributes=(attrs)
    self.article_type ||= 'Device'
    self.article.attributes = attrs
  end

  def service_attributes=(attrs)
    self.article_type ||= 'Service'
    self.article.attributes = attrs
  end

end

