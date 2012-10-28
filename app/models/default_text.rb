class DefaultText < ActiveRecord::Base
  belongs_to :company_section

  validates_presence_of :name, :value

  validates_length_of :name,
      :within => 2..100
  validates_length_of :value,
      :within => 1..2000

  attr_protected :company_section_id

  def to_s
    self.value || "-- undefined: #{self.value} --"
  end

end
