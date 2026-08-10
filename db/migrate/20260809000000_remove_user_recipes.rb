class RemoveUserRecipes < ActiveRecord::Migration[8.1]
  def up
    return unless table_exists?(:user_recipes)

    remove_foreign_key :user_recipes, :recipes if foreign_key_exists?(:user_recipes, :recipes)
    remove_foreign_key :user_recipes, :users if foreign_key_exists?(:user_recipes, :users)
    drop_table :user_recipes
  end

  def down
    create_table :user_recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_recipes, [ :user_id, :recipe_id ], unique: true
  end
end
