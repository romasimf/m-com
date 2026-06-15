class AddNotificationFields < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:messages, :read_at)
      add_column :messages, :read_at, :datetime
    end

    unless index_exists?(:messages, [:conversation_id, :read_at])
      add_index :messages, [:conversation_id, :read_at]
    end

    unless column_exists?(:users, :notifications_seen_at)
      add_column :users, :notifications_seen_at, :datetime
    end
  end
end