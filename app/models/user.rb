class User < ActiveRecord::Base
  include Concerns::CompanyAsset
  include Concerns::Addressable
  include Random

  has_many :clients,
      :foreign_key => :contact_person_id
  has_many :rentals
  has_many :sellings

  acts_as_authentic

  validates_presence_of :login,
      :forename,
      :surname

  def full_name_with_section
    "#{self.full_name} (#{self.company_section.name})"
  end

  def full_name_with_company_and_section
    "#{self.full_name} (#{self.company_section.full_name})"
  end

  def company
    self.company_section.company
  end

  def is_admin?
    login == 'wvk'
  end

  def before_destroy
    case
    when self.company.admin_id == self.id
      raise 'Der Administrator kann nicht gelöscht werden.'
    when self.clients.any?
      raise "Der Benutzer ist noch Ansprechpartner für #{self.clients.count} Kunden"
    when self.rentals.any?
      raise "Der Benutzer hat #{self.rentals.size} Vermietvorgänge"
    when self.sellings.any?
      raise "Der Benutzer hat #{self.selings.size} Verkaufsvorgänge"
    end
  end

end
