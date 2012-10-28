class Address < ActiveRecord::Base

  def used?
    (self.attributes.keys - ['id', 'updated_at', 'created_at']).any? {|key| !attributes[key].blank? }
  end

  def to_html
    <<-EOS
    #{self.street}<br />
    #{self.postalcode} #{self.locality}<br />
    #{self.country}
    EOS
  end

end
