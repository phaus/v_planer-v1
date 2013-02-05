class CreateCommercialProcesses < ActiveRecord::Migration
  def self.up
    create_table :commercial_processes do |t|
      t.integer  :client_id,                      :limit => 8
      t.integer  :sender_id
      t.integer  :created_by_id
      t.integer  :updated_by_id
      t.string   :workflow_state
      t.string   :process_no
      t.string   :title,                                                                         :default => ''
      t.string   :remarks,                        :limit => 2048
      t.string   :offer_top_text,                 :limit => 2048
      t.string   :offer_bottom_text,              :limit => 2048
      t.string   :offer_confirmation_top_text,    :limit => 1000
      t.string   :offer_confirmation_bottom_text, :limit => 1000
      t.decimal  :discount,                                       :precision => 10, :scale => 2
      t.decimal  :client_discount,                                :precision => 10, :scale => 2
      t.integer  :implementation_id
      t.string   :implementation_type
      t.timestamps
    end
  end

  def self.down
    drop_table :commercial_processes
  end
end
