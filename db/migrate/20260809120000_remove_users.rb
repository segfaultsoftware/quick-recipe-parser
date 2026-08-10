class RemoveUsers < ActiveRecord::Migration[8.1]
  def up
    drop_table :users
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The users table and account data cannot be restored"
  end
end
