# Class for creating  Articles, that are stored in the database. Expanded database made by Artur Jaakman.

class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.string :heading 
      t.string :content
      t.string :author
      t.boolean :approved
      t.string :approver
      t.string :lasteditor
      t.timestamps null: false 
    end
  end
end