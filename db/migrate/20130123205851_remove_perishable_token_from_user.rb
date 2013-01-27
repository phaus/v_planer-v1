class RemovePerishableTokenFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :perishable_token
    remove_column :users, :last_request_at
  end

  def down
    add_column :users, :perishable_token,    :string, :null => false, :default => ''  # optional, see Authlogic::Session::Perishability
    add_column :users, :last_request_at,     :datetime                                # optional, see Authlogic::Session::MagicColumns

  end
end
