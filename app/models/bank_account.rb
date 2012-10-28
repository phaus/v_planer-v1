class BankAccount < ActiveRecord::Base

  def used?
    (self.attributes.keys - ['id', 'updated_at', 'created_at']).any? {|key| !attributes[key].blank? }
  end

end
