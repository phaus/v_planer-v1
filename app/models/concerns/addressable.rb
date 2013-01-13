module Concerns
  module Addressable
    extend ActiveSupport::Concern

    included do
      belongs_to :address
      belongs_to :bank_account

      accepts_nested_attributes_for :address
      accepts_nested_attributes_for :bank_account

      validate :presence_of_company_name_or_full_name
    end

    module ClassMethods

    end

    module InstanceMethods
      def full_name
        "#{self.forename} #{self.surname}"
      end

      def full_name
        str = "#{self.title} #{self.forename} #{self.surname}"
        str.blank? ? "Fa. #{self.company_name}" : str
      end

      def presence_of_company_name_or_full_name
        if self.company_name.blank? and self.full_name.blank?
          errors.add 'Firmenname und Personenname dürfen nicht beide leer sein.'
        end
      end
    end

  end
end
