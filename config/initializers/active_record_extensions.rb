module CompanySectionSpecifics
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def is_company_specific
      self.named_scope :for_company, lambda {|company|
        { :joins      => "JOIN company_sections ON company_sections.id = #{table_name}.company_section_id
                          JOIN companies ON companies.id = company_sections.company_id",
          :conditions => ['companies.id = ?', company.id]
        }
      }
    end
  end
end

module MoneyHandling
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def monetary_value(*names)
      names.flatten.each do |name|
        define_method :"#{name}" do
          val = self.read_attribute(:"#{name}_i")
          val ? (val.to_f / 100) : nil
        end

        define_method :"#{name}=" do |new_price|
          self.write_attribute :"#{name}_i", new_price.blank? ? nil : (new_price.to_s.gsub(',', '.').to_f * 100)
        end
      end
    end
  end
end

module ErrorCollection
  def self.included(base)
    base.extend ClassMethods
    base.class_inheritable_array :collector_assocs
  end

  def collect_errors
    self.class.read_inheritable_attribute(:collector_assocs).each do |association_name|
      collector = proc {|o, n| o.errors.each {|err, msg| self.errors.add("#{n} (#{err})", msg) } }
      association_type = self.class.reflect_on_association(association_name).macro
      case association_type
      when :has_many, :has_and_belongs_to_many
        self.send(association_name).each_with_index {|e, i| collector.call(e, "#{association_name}[#{i}]") }
      when :has_one, :belongs_to
        assoc_obj = self.send(association_name)
        collector.call assoc_obj, association_name unless assoc_obj.nil?
      else
        raise "unsupported association type: #{association_type}"
      end
    end
  end

  module ClassMethods

    def collect_errors_from(*associations)
      after_validation :collect_errors
      associations.flatten.each do |assoc|
        write_inheritable_attribute(:collector_assocs, (read_inheritable_attribute(:collector_assocs) || []) | [assoc])
      end
    end
    alias collects_errors_from collect_errors_from
  end

end

ActiveRecord::Base.send :include, CompanySectionSpecifics
ActiveRecord::Base.send :include, MoneyHandling
ActiveRecord::Base.send :include, ErrorCollection

