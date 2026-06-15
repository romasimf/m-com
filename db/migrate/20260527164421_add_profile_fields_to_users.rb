class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:users, :name)
      add_column :users, :name, :string
    end

    unless column_exists?(:users, :username)
      add_column :users, :username, :string
    end

    unless index_exists?(:users, :username)
      add_index :users, :username, unique: true
    end
  end
end