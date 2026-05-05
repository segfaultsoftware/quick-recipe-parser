class CreateUserRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :user_recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_recipes, [ :user_id, :recipe_id ], unique: true
  end
end
