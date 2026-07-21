class CreateSupportRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :support_requests do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 1, null: false
      t.references :creator, null: false, foreign_key: { to_table: :team_members }
      t.references :assignee, null: true, foreign_key: { to_table: :team_members }
      t.references :team, null: false, foreign_key: { to_table: :team_members }
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :support_requests, :status
    add_index :support_requests, :priority
  end
end
