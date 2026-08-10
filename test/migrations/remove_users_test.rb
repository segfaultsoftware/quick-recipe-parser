require "test_helper"
require_relative "../../db/migrate/20260809120000_remove_users"

class RemoveUsersTest < ActiveSupport::TestCase
  test "removes users without changing shared recipe data" do
    connection = ActiveRecord::Base.connection
    create_users_table(connection)
    assert connection.data_source_exists?("users")

    user_model = Class.new(ActiveRecord::Base) do
      self.table_name = "users"
    end
    user_model.create!(name: "Test User")

    recipe_snapshot = Recipe.order(:id).pluck(:id, :name, :reference_url)
    ingredient_snapshot = Ingredient.order(:id).pluck(:id, :name)
    recipe_ingredient_snapshot = RecipeIngredient.order(:id).pluck(
      :id,
      :recipe_id,
      :ingredient_id,
      :number_of_units,
      :unit_of_measurement
    )

    RemoveUsers.new.migrate(:up)

    assert_not connection.data_source_exists?("users")
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
end
