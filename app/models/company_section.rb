class CompanySection < ActiveRecord::Base
  belongs_to :company
  belongs_to :address
  belongs_to :bank_account
  has_many :users
  has_many :products
  has_many :rentals,
      :foreign_key => :sender_id
  has_many :sellings,
      :foreign_key => :sender_id
  has_many :commercial_processes,
      :foreign_key => :sender_id
  has_many :default_texts

  validates_presence_of :name

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :bank_account

  def is_main?
    self.company.main_section_id == self.id
  end

  def full_name
    "#{company.name}: #{name}"
  end

  def bank_details_valid?
    return false unless self.bank_account
    self.bank_account.registrar_name and self.bank_account.bank_name and
        (self.bank_account.blz and self.bank_account.number or
        self.bank_account.iban and self.bank_account.bic)
  end

  def sender_address_block
    self.read_attribute(:sender_address_block).gsub(/%([a-z_]+)/) do |match|
      self.read_attribute(match[1..-1])
    end
  end

  def sender_address_window
    self.read_attribute(:sender_address_window).gsub(/%([a-z_]+)\b/) do |match|
      self.read_attribute(match[1..-1])
    end
  end

  class TextProxy
    def initialize(proxy_owner)
      @proxy_owner = proxy_owner
    end

    def [](key)
      @proxy_owner.default_texts.where(:name => key.to_s).first.to_s
    end
  end

  def text
    @text_proxy ||= TextProxy.new(self)
  end

end
