class CreateDefaultTexts < ActiveRecord::Migration
  def self.up
    create_table :default_texts do |t|
      t.string  :name,               :limit => 100
      t.string  :value,              :limit => 2000
      t.integer :company_section_id

      t.timestamps
    end
  end

  def self.down
    drop_table :default_texts
  end
end
