class Initial < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string  :name
      t.text    :description
      t.integer :width,  :limit => 10
      t.integer :height, :limit => 10
      t.integer :length, :limit => 10
      t.integer :weight, :limit => 10
      t.string  :image
      t.boolean :is_container
      t.string  :code
      t.timestamps
    end

    create_table :clients do |t|
      t.string :forename
      t.string :surname
      t.string :title
      t.string :password
      t.string :company
      t.string :phone
      t.string :email
      t.date :birthday

      t.timestamps
    end

    create_table :categories do |t|
      t.string :name
      t.string :description

      t.timestamps
    end

    create_table :categories_devices do |t|
      t.integer :device_id,   :limit => 10
      t.integer :category_id, :limit => 10
    end

    create_table :rental_periods do |t|
      t.integer :client_id, :limit => 10
      t.integer :device_id, :limit => 10
      t.datetime :from_date
      t.datetime :to_date
      t.text :comments

      t.timestamps
    end

    create_table :device_occupations do |t|
      t.integer :device_id, :limit => 10
      t.datetime :from_date
      t.datetime :to_date
      t.text :comments

      t.timestamps
    end

    create_table :device_containments do |t|
      t.integer :rental_period_id, :limit => 10
      t.integer :container_id,     :limit => 10
      t.integer :device_id,        :limit => 10
    end
  end

  def self.down
  end
end
