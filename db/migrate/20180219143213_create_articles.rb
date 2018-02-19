# Class for creating  Articles, that are stored in the database.

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
      Article.create(heading: "testheading", content: "testcontent testcontent testcontent testcontent testcontent testcontent testcontent", author: "Admin", approved: true, approver: "Admin")
      Article.create(heading: "test2", content: "testcontent2 text texttexttext texttext texttestcontent testcontent testcontent testcontent testcontent", author: "Admin", approved: true, approver: "Admin")

    end
end