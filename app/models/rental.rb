class Rental < CommercialProcess
  include Conforming::ModelExtensions

  has_many :device_items,
      :class_name => 'RentalPeriod',
      :dependent  => :destroy,
      :after_add  => :create_reverse_association_in_item

  has_many :service_items,
      :as         => :process,
      :dependent  => :destroy,
      :after_add  => :create_reverse_association_in_item

  validates_presence_of :client,
      :sender,
      :discount,
      :client_discount,
      :usage_duration,
      :billed_duration,
      :user,
      :begin,
      :end

  scope :for_company, lambda { |company|
    where :sender_id => company.section_ids
  }

  scope :with_state, lambda { |*states|
    where :workflow_state => states.flatten
  }

  accepts_nested_attributes_for :device_items,
      :allow_destroy => true,
      :reject_if     => lambda {|d| d['count'].blank? or d['count'].to_f == 0.0 or d['product_attributes'] and d['product_attributes']['name'].blank? }

  accepts_nested_attributes_for :service_items,
      :allow_destroy => true,
      :reject_if     => lambda {|d| d['count'].blank? or d['count'].to_f == 0.0 or d['product_attributes'] and d['product_attributes']['name'].blank? }

  monetary_value :discount,
      :client_discount

  scope :for_current_month, where(['begin < ? AND end > ?', Date.today.at_end_of_month, Date.today.at_beginning_of_month])

  collect_errors_from :device_items, :service_items

  def items
    self.device_items + self.service_items
  end

  def new_service_items_attributes=(attrs)
    attrs = attrs.is_a?(Hash) ? attrs.values : attrs
    self.service_items_attributes = attrs.reject{|a| a[:count].to_i == 0 || a[:duration].to_f == 0.0}
  end

  def new_device_items_attributes=(attrs)
    attrs = attrs.is_a?(Hash) ? attrs.values : attrs
    self.device_items_attributes = attrs.reject{|a| a[:count].to_i == 0}
  end

  def new_device_items
    self.device_items
  end

  def new_service_items
    self.service_items
  end

  def to_pdf
    PdfRental.new(self).to_s
  end

  def to_pdf_offer_confirmation
    PdfOfferConfirmation.new(self).to_s
  end

  def to_pdf_offer
    PdfOffer.new(self).to_s
  end

  def to_pdf_packing_note
    PdfPackingNote.new(self).to_s
  end

  default_value_for :service_sum do
    self.service_items.collect(&:price).sum
  end

  default_value_for :device_sum do
    self.device_items.collect(&:price).sum
  end

  default_value_for :sum do
    self.service_sum + self.device_sum
  end

  def from_date
    self.begin
  end

  def to_date
    self.end
  end

  def client_discount_percent
    return 0.0 if sum.to_f == 0.0
    ((client_discount / sum.to_f) * 100000.0).round / 1000.0
  end

  default_value_for :net_total_price do
    self.sum - self.client_discount - self.discount
  end

  default_value_for :billed_duration do
    DISCOUNT_RATES[self.usage_duration.floor]
  end

  default_value_for :usage_duration do
    self.duration
  end

  default_value_for :duration do
    if self.from_date == self.to_date
      1.0
    else
      ((self.to_date - self.from_date) / 1.day).to_f
    end
  end

  default_value_for :offer_top_text, :type => String do
    self.sender.text[:rental_offer_top_text]
  end

  def evaluated_offer_top_text
    offer_top_text.gsub(/(%[a-z_]+)/) do |match|
      { '%sender_name'     => self.user.full_name,
        '%usage_duration'  => self.usage_duration,
        '%from_date'       => Date.parse(self.from_date.to_s),
        '%to_date'         => Date.parse(self.to_date.to_s),
        '%billed_duration' => self.billed_duration
      }[match]
    end
  end

  default_value_for :offer_bottom_text, :type => String do
    self.sender.text[:rental_offer_bottom_text]
  end

  def evaluated_offer_bottom_text
    offer_bottom_text.gsub(/(%[a-z_]+)/) do |match|
      {'%sender_name' => self.user.full_name}[match]
    end
  end

  default_value_for :offer_confirmation_top_text, :type => String do
    self.sender.text[:rental_offer_confirmation_top_text]
  end

  def evaluated_offer_confirmation_top_text
    offer_confirmation_top_text.gsub(/(%[a-z_]+)/) do |match|
      { '%sender_name'     => self.user.full_name,
        '%usage_duration'  => self.usage_duration,
        '%from_date'       => Date.parse(self.from_date.to_s),
        '%to_date'         => Date.parse(self.to_date.to_s),
        '%billed_duration' => self.billed_duration
      }[match]
    end
  end

  default_value_for :offer_confirmation_bottom_text, :type => String do
    self.sender.text[:rental_offer_confirmation_bottom_text]
  end

  def evaluated_offer_confirmation_bottom_text
    offer_confirmation_bottom_text.gsub(/(%[a-z_]+)/) do |match|
      {'%sender_name' => self.user.full_name}[match]
    end
  end

  # workflow method
  def reject
    self[:count] = self.count
    self.device_items.each do |item|
      item.unavailabilities.delete_all
    end
  end

  # workflow method
  def accept
    if current_state == :rejected
      self.device_items.each do |item|
        item.count = item.count # this forces the unavailabilities to be updated
      end
    end
  end

  protected

  def create_reverse_association_in_item(item)
    item.process = self
  end

end
