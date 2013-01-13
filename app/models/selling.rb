class Selling < CommercialProcess
  include Conforming::ModelExtensions

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

  scope :for_company, lambda { |company|
    where :sender_id => company.section_ids
  }

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
