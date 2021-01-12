class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :fname
      t.string :lname
      t.date :bdate
      t.string :email
      t.integer :age
      t.string :gender

      t.timestamps
    end
  end
end
