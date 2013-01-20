class ProcessItem < ActiveRecord::Base
  include Conforming::ModelExtensions

  belongs_to :commercial_process

  belongs_to :product

  belongs_to :cost_calculation,
      :polymorphic => true

  delegate :total_net_price, :total_gross_price,
      :to => :cost_calculation

  validates_presence_of :unit, :quantity, :name, :vat_percentage, :cost_calculation

  after_initialize :set_default_cost_calculation

  accepts_nested_attributes_for :cost_calculation,
      :update_only => true

  default_value_for :name, :type => String do
    self.product.try :name
  end

  default_value_for :unit, :type => String do
    self.product.try :unit
  end

  default_value_for :remarks, :type => String do
    self.product.try :description
  end

  default_value_for :quantity do
    1.0
  end

  default_value_for :vat_percentage do
    self.product.try(:vat_percentage) || 19.0
  end

  def cost_calculation_with_reverse_assiciation_assignment
    cc = cost_calculation_without_reverse_assiciation_assignment
    cc ? cc.tap {|a| a.item = self } : nil
  end
  alias_method_chain :cost_calculation, :reverse_assiciation_assignment

  def preview=(val)
    if val
      CALCULATED_ATTRIBUTES.each do |key, val|
        self.send "#{key}=", 'reset'
      end
    end
  end

  protected

  def set_default_cost_calculation
    self.cost_calculation ||= TrivialCostCalculation.new(:item => self)
  end

end
