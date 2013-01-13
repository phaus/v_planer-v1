module Concerns
  module CompanyAsset
    extend ActiveSupport::Concern

    included do
      belongs_to :company_section
      has_one :company, :through => :company_section
      scope :for_company, lambda {|company| joins(:company_section).where(['company_sections.company_id = ?', company.id]) }

      attr_protected :company_section_id, :company_section

      validates_presence_of :company_section
    end

    module ClassMethods

    end

    module InstanceMethods

    end
  end
end
