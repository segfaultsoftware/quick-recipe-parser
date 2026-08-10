class RemoveUserRecipes < ActiveRecord::Migration[8.1]
  def up
    remove_foreign_key :user_recipes, :recipes
    remove_foreign_key :user_recipes, :users
    drop_table :user_recipes
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The user_recipes table and its ownership data cannot be restored"
  end
end
