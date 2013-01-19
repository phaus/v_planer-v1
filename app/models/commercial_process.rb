require 'workflow'

class CommercialProcess < ActiveRecord::Base
  include Workflow
  include Conforming::ModelExtensions

  attr_accessor :acting_user

  has_one :invoice,
      :as        => 'process',
      :dependent => :destroy

  has_many :items,
      :class_name => 'ProcessItem'

  belongs_to :client

  belongs_to :sender,
      :class_name => 'CompanySection'

  belongs_to :created_by,
      :class_name => 'User'

  belongs_to :updated_by,
      :class_name => 'User'

  before_create :set_created_by
  before_update :set_updated_by

  validate :no_invoice_yet

  validates_presence_of :client,
      :sender,
      :process_no
#       :discount,
#       :client_discount,

  scope :for_company, lambda {|company|
    where :sender_id => company.section_ids
  }

  scope :with_state, lambda {|*states|
    where :workflow_state => states.flatten
  }

  delegate :full_name,
      :to     => :created_by,
      :prefix => true

  delegate :full_name,
      :to     => :updated_by,
      :prefix => true

  workflow do
    state :uninitialized do
      event :init, :transitions_to => :new
    end

    state :new do
      event :add_item, :transitions_to => :new
      event :update_attributes, :transitions_to => :new
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected
      event :close,  :transitions_to => :closed
    end

    state :accepted do
      event :update_attributes, :transitions_to => :new
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

    on_transition do |from_state, to_state, event, *args|
      Rails.logger.info "\e[1;37m[CommercialProcess STATE MACHINE]\e[0m (#{from_state})\e[1;32m-[#{event}(#{args.first.inspect})]->\e[0m(#{to_state})"
    end

    on_failed_transition do |from_state, to_state, event, *args|
      if self.halted_because.blank?
        if self.valid?
          message = 'no reason given'
          @halted_because = :unknown_reason
        else
#           message = 'Validation failed: %s' % self.errors.full_messages.join(', ')
          @halted_because = :validation_failed
        end
      else
        message = I18n.t(self.halted_because, :scope => 'workflow.halted_because.commercial_process')
      end
      self.errors.add :base, message if message
      Rails.logger.info "\e[1;31m[CommercialProcess STATE MACHINE]\e[0m (#{from_state})\e[1;32m-[#{event}(#{args.first.inspect})]->\e[0m(#{to_state}) \e[1;31mFAILED: #{message}\e[0m."
    end
  end

  def prepare_invoice(attrs = {})
    as_user options.delete(:as) do |user|
      invoice = self.build_invoice :client => self.client,
          :sender     => self.sender,
          :user       => user,
          :date       => Date.today,
          :price      => self.total_gross_price,
          :invoice_no => (Invoice.maximum(:invoice_no)||0).succ
      invoice.attributes = attrs
      self.items.each do |period|
        invoice.items.build(:item => period)
      end
      invoice
    end
  end

  def create_invoice(attrs={})
    invoice = prepare_invoice(attrs)
    invoice.save!
    invoice
  end

  def process_no
    self.implementation.process_no
  rescue
    self.new_record? ? (self.class.maximum(:id) || 0).succ : self.id
  end

  default_value_for :client_discount do
    self.client.try(:discount) || 0.0
  end

  default_value_for :discount do
    0.0
  end

  default_value_for :total_gross_price do
    self.total_net_price + self.vat
  end

  default_value_for :vat do
    self.total_net_price * 0.19
  end

  def client_discount_percent
    return 0.0 if sum.to_f == 0.0
    (self.client_discount / self.total_net_price).round(2)
  end

  def total_net_price
    self.sum - self.client_discount - self.discount
  end

  def sum
    self.items.map(&:total_net_price).sum
  end

  def init(options)
    as_user options.delete(:as) do |user|
      self.sender = user.company_section
      self.attributes = options
    end
  end

  def add_item(options)
    as_user options.delete(:as) do |user|
      self.build_item do |item|
        item.created_by = user
        item.attributes = options[:item_attributes]
        halt :validation_failed unless item.valid?
      end
    end
  end

  def as_user(user, &block)
    if user.blank?
      halt :missing_acting_user
      false
    elsif self.sender and self.sender != user.company_section
      halt :user_does_not_belong_to_same_company_section_as_process
      false
    else
      @acting_user = user
      yield user
    end
  end

  protected

  def no_invoice_yet
    if self.invoice
      self.errors.add :base, 'Dieser Vorgang wurde bereits abgerechnet und kann daher nicht mehr verändert werden.'
    end
  end

  def load_workflow_state
    if self.client.nil? or self.process_no.blank?
      'uninitialized'
    else
      self[:workflow_state]
    end
  end

  def persist_workflow_state(state = nil)
    self.update_attributes :workflow_state => state || self.current_state
  end

  def set_created_by
    raise 'missing acting user' if @acting_user.nil?
    self.created_by = @acting_user
    self.updated_by = @acting_user
  end

  def set_updated_by
    self.updated_by = @acting_user or raise 'missing acting user'
  end


end
