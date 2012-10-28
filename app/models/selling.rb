class Selling < CommercialProcess

  has_many :device_items,
      :class_name => 'SellingItem',
      :foreign_key => 'process_id'

  has_many :service_items,
      :class_name => 'ServiceItem',
      :foreign_key => 'process_id'

  accepts_nested_attributes_for :device_items,
      :reject_if     => proc { |attrs| attrs[:count].to_i == 0 },
      :allow_destroy => true

  accepts_nested_attributes_for :service_items,
      :reject_if     => proc { |attrs| attrs[:count].sub(',', '.').to_f == 0.0 },
      :allow_destroy => true

  named_scope :for_company, lambda { |company|
    { :conditions => ['sender_id IN (?)', company.section_ids]}
  }

  monetary_value :discount, :client_discount

  def items
    self.device_items + self.service_items
  end

  def sum
    self.device_sum + self.service_sum
  end

  def device_sum
    self.device_items.collect(&:price).sum
  end

  def service_sum
    self.service_items.collect(&:price).sum
  end

  def client_discount_percent
    return 0.0 if sum.to_f == 0.0
    ((self.client_discount / self.sum.to_f) * 100000.0).round / 1000.0
  end

  def net_total_price
    self.sum - self.client_discount - self.discount
  end

  def gross_total_price
    val = self.read_attribute(:price_i)
    val ? val / 100.0 : self.net_total_price + self.vat
  end

  def vat
    self.net_total_price * 0.19
  end

  def new_device_items_attributes=(attrs)
    self.device_items_attributes = attrs
  end

  def new_device_items
    self.device_items
  end

  def new_service_items_attributes=(attrs)
    self.service_items_attributes = attrs
  end

  def new_service_items
    self.service_items
  end

  def to_pdf
    PdfSelling.new(self).to_s
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

  def offer_top_text
    self.read_attribute(:offer_top_text) || self.sender.text[:selling_offer_top_text]
  end

  def evaluated_offer_top_text
    offer_top_text.gsub(/(%[a-z_]+)/) do |match|
      { '%sender_name' => self.user.full_name }[match]
    end
  end

  def offer_bottom_text
    self.read_attribute(:offer_bottom_text) || self.sender.text[:selling_offer_bottom_text]
  end

  def evaluated_offer_bottom_text
    offer_bottom_text.gsub(/(%[a-z_]+)/) do |match|
      {'%sender_name' => self.user.full_name}[match]
    end
  end

  def offer_confirmation_top_text
    self.read_attribute(:offer_confirmation_top_text) || self.sender.text[:selling_offer_confirmation_top_text]
  end

  def evaluated_offer_confirmation_top_text
    offer_confirmation_top_text.gsub(/(%[a-z_]+)/) do |match|
      { '%sender_name' => self.user.full_name }[match]
    end
  end

  def offer_confirmation_bottom_text
    self.read_attribute(:offer_confirmation_bottom_text) || self.sender.text[:selling_offer_confirmation_bottom_text]
  end

  def evaluated_offer_confirmation_bottom_text
    offer_confirmation_bottom_text.gsub(/(%[a-z_]+)/) do |match|
      {'%sender_name' => self.user.full_name}[match]
    end
  end

end
