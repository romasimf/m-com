class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :user_one, null: false, foreign_key: { to_table: :users }
      t.references :user_two, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :conversations, [:user_one_id, :user_two_id], unique: true
    add_check_constraint :conversations, "user_one_id <> user_two_id", name: "conversations_users_not_equal"
  end
end