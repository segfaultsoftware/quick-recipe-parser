require "test_helper"
require_relative "../../db/migrate/20260808120000_remove_user_recipes"

class RemoveUserRecipesTest < ActiveSupport::TestCase
  test "removes ownership join without changing shared recipe data" do
    connection = ActiveRecord::Base.connection
    create_users_table(connection)
    create_user_recipes_table(connection)

    recipe_snapshot = Recipe.order(:id).pluck(:id, :name, :reference_url)
    ingredient_snapshot = Ingredient.order(:id).pluck(:id, :name)
    recipe_ingredient_snapshot = RecipeIngredient.order(:id).pluck(
      :id,
      :recipe_id,
      :ingredient_id,
      :number_of_units,
      :unit_of_measurement
    )

    ownership_model = Class.new(ActiveRecord::Base) do
      self.table_name = "user_recipes"
    end
    user_model = Class.new(ActiveRecord::Base) do
      self.table_name = "users"
    end
    user = user_model.create!(name: "Test User")
    ownership_model.create!(user_id: user.id, recipe_id: recipes(:one).id)

    RemoveUserRecipes.new.migrate(:up)

    assert_not connection.data_source_exists?("user_recipes")
    assert_equal recipe_snapshot, Recipe.order(:id).pluck(:id, :name, :reference_url)
    assert_equal ingredient_snapshot, Ingredient.order(:id).pluck(:id, :name)
    assert_equal recipe_ingredient_snapshot, RecipeIngredient.order(:id).pluck(
      :id,
      :recipe_id,
      :ingredient_id,
      :number_of_units,
      :unit_of_measurement
    )
  end

private

  def create_users_table(connection)
    connection.create_table :users do |table|
      table.string :avatar_url
      table.string :email
      table.string :google_uid
      table.string :name
      table.timestamps
    end
  end

  def create_user_recipes_table(connection)
    connection.create_table :user_recipes do |table|
      table.bigint :user_id, null: false
      table.bigint :recipe_id, null: false
      table.timestamps
    end

    connection.add_foreign_key :user_recipes, :users
    connection.add_foreign_key :user_recipes, :recipes
  end
end
