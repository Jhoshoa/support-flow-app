class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.text :body, null: false
      t.references :support_request, null: false, foreign_key: true
      t.references :team_member, null: false, foreign_key: true

      t.timestamps
    end
  end
end
