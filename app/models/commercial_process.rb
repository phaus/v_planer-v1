require 'workflow'

class CommercialProcess < ActiveRecord::Base
  include Workflow

  self.abstract_class = true

  has_one :invoice,
      :as        => 'process',
      :dependent => :destroy

  belongs_to :client

  belongs_to :sender,
      :class_name => 'CompanySection'

  belongs_to :user

  validate :no_invoice_yet

  named_scope :for_company, lambda { |company|
    { :conditions => ['sender_id IN (?)', company.section_ids]}
  }

  named_scope :with_state, lambda { |*states|
    { :conditions => ['workflow_state IN (?)', states.flatten]}
  }

  workflow do
    state :new do
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected
      event :close,  :transitions_to => :closed
    end
    state :accepted do
      event :create_invoice, :transitions_to => :billed
      event :reject, :transitions_to => :rejected
      event :close,  :transitions_to => :closed
    end
    state :rejected do
      event :accept, :transitions_to => :accepted
      event :close,  :transitions_to => :closed
    end
    state :billed do
      event :receive_payment, :transitions_to => :payed
      event :remove_invoice, :transitions_to => :accepted
      event :close,  :transitions_to => :closed
    end
    state :payed
    state :closed
  end

  def prepare_invoice(attrs = {})
    invoice = self.build_invoice :client => self.client,
        :sender     => self.sender,
        :user       => self.user,
        :date       => Date.today,
        :price      => self.gross_total_price,
        :invoice_no => (Invoice.maximum(:invoice_no)||0).succ
    invoice.attributes = attrs
    self.items.each do |period|
      invoice.items.build(:item => period)
    end
    invoice
  end

  def create_invoice(attrs={})
    invoice = prepare_invoice(attrs)
    invoice.save!
    invoice
  end

  def process_no
    case self
    when Rental
      self.sender.company.rental_process_no_format.gsub(/%id/, self.id.to_s)
    when Selling
      self.sender.company.selling_process_no_format.gsub(/%id/, self.id.to_s)
    else
      raise 'unknown process type'
    end
  rescue
    self.id.to_s
  end

  protected

  def no_invoice_yet
    if self.invoice
      errors.add_to_base 'Dieser Vorgang wurde bereits abgerechnet und kann daher nicht mehr verändert werden.'
      return false
    else
      return true
    end
  end

end
