require 'workflow'

class CommercialProcess < ActiveRecord::Base
  include Workflow
  include Conforming::ModelExtensions

  self.abstract_class = true

  has_one :invoice,
      :as        => 'process',
      :dependent => :destroy

  belongs_to :client

  belongs_to :sender,
      :class_name => 'CompanySection'

  belongs_to :user

  validate :no_invoice_yet

  scope :for_company, lambda {|company|
    where :sender_id => company.section_ids
  }

  scope :with_state, lambda {|*states|
    where :workflow_state => states.flatten
  }

  workflow do
    state :uninitialized do
      event :select_client, :transitions_to => :new
    end

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

  default_value_for :client_discount do
    self.client.try(:discount) || 0.0
  end

  default_value_for :discount do
    0.0
  end

  default_value_for :gross_total_price do
    self.net_total_price + self.vat
  end

  default_value_for :vat do
    self.net_total_price * 19.0 / 100.0
  end

  def client_discount_percent
    return 0.0 if sum.to_f == 0.0
    ((self.client_discount / self.sum.to_f) * 100000.0).round / 1000.0
  end

  def net_total_price
    self.sum - self.client_discount - self.discount
  end

  def select_client(options)
    as_user = options.delete(:as)
    if as_user.blank?
      halt :missing_acting_user
    else
      self.user   = as_user
      self.sender = as_user.company_section
      self.attributes = options
      halt :missing_client if self.client.nil?
    end
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

  def load_workflow_state
    if self.client.nil? or self.process_no.blank?
      'uninitialized'
#     elsif self.invoice.nil?
    else
      self[:workflow_state]
    end
  end

  def persist_workflow_state(state)
    self[:workflow_state] = state
  end

end
