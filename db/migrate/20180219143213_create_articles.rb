# Class for creating Users, that are stored in the database.

class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.string :heading 
      t.string :content
      t.string :author
      t.boolean :approved
      t.string :approver
      t.timestamps null: false 
    end
      Article.create(heading: "testheading", content: "testcontent")
  end
end