class Rental < CommercialProcess
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
      :discount_i,
      :client_discount_i,
      :usage_duration,
      :billed_duration,
      :user,
      :begin,
      :end

  named_scope :for_company, lambda { |company|
    { :conditions => ['sender_id IN (?)', company.section_ids]}
  }

  named_scope :with_state, lambda { |*states|
    { :conditions => ['workflow_state IN (?)', states.flatten]}
  }

  accepts_nested_attributes_for :device_items,
      :allow_destroy => true,
      :reject_if     => lambda {|d| d['count'].blank? or d['count'].to_f == 0.0 or d['product_attributes'] and d['product_attributes']['name'].blank? }

  accepts_nested_attributes_for :service_items,
      :allow_destroy => true,
      :reject_if     => lambda {|d| d['count'].blank? or d['count'].to_f == 0.0 or d['product_attributes'] and d['product_attributes']['name'].blank? }

  monetary_value :discount,
      :client_discount

  named_scope :for_current_month,
      :conitions => ['begin < ? AND end > ?', Date.today.at_end_of_month, Date.today.at_beginning_of_month]

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

  def service_sum
    self.service_items.collect(&:price).sum
  end

  def device_sum
    self.device_items.collect(&:price).sum
  end

  def sum
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

  def net_total_price
    self.sum - (self.client_discount || 0) - (self.discount || 0)
  end

  def gross_total_price
    val = self.read_attribute(:price_i)
    val ? val / 100.0 : self.net_total_price + self.vat
  end

  def vat
    self.net_total_price.to_f * 19.0 / 100.0
  end

  def billed_duration
    self.read_attribute(:billed_duration) || DISCOUNT_RATES[self.usage_duration.floor]
  end

  def usage_duration
    self.read_attribute(:usage_duration) || self.duration
  end

  def usage_duration
    self.read_attribute(:usage_duration) || self.duration
  end

  def duration
    if self.from_date == self.to_date
      1.0
    else
      ((self.to_date - self.from_date) / 1.day).to_f
    end
  end

  def offer_top_text
    self.read_attribute(:offer_top_text) || self.sender.text[:rental_offer_top_text]
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

  def offer_bottom_text
    self.read_attribute(:offer_bottom_text) || self.sender.text[:rental_offer_bottom_text]
  end

  def evaluated_offer_bottom_text
    offer_bottom_text.gsub(/(%[a-z_]+)/) do |match|
      {'%sender_name' => self.user.full_name}[match]
    end
  end

  def offer_confirmation_top_text
    self.read_attribute(:offer_confirmation_top_text) || self.sender.text[:rental_offer_confirmation_top_text]
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

  def offer_confirmation_bottom_text
    self.read_attribute(:offer_confirmation_bottom_text) || self.sender.text[:rental_offer_confirmation_bottom_text]
  end

  def evaluated_offer_confirmation_bottom_text
    offer_confirmation_bottom_text.gsub(/(%[a-z_]+)/) do |match|
      {'%sender_name' => self.user.full_name}[match]
    end
  end

  def reject
    self[:count] = self.count
    self.device_items.each do |item|
      item.unavailabilities.delete_all
    end
  end

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
