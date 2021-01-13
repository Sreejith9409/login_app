class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name, :limit => 32
      t.string :last_name, :limit => 32
      t.boolean :delete_flag, :default => false
      t.string :email
      t.integer :age
      t.string :gender
      t.string :login
      t.string :crypted_password
      t.string :salt, :limit => 40
      t.string :home_number, :limit => 20
      t.string :mobile_number, :limit => 20
      t.string :work_number, :limit => 20
      t.string :fax_number, :limit => 20
      t.string :other_numbers, :limit => 64
      t.string :address, :limit => 128
      t.string :city
      t.string :state
      t.integer :pin_code, :limit => 6
      t.string :country
      t.string :auth_token
      t.timestamps
    end
  end
end
