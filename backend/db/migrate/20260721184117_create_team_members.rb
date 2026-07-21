class CreateTeamMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :team_members do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.integer :role, default: 0, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :team_members, :email, unique: true
  end
end
