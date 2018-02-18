# Class for creating Users, that are stored in the database.

class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username 
      t.string :password
      t.boolean :edit
      t.timestamps null: false 
    end
      User.create(username: "Admin", password: "admin", edit: true) # Creating and Admin account.
  end
end