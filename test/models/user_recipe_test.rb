require "test_helper"

class UserRecipeTest < ActiveSupport::TestCase
  test "valid user_recipe" do
    user_recipe = user_recipes(:one)
    assert user_recipe.valid?
  end

  test "prevents duplicate user-recipe pairs" do
    existing = user_recipes(:one)
    duplicate = UserRecipe.new(user: existing.user, recipe: existing.recipe)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "requires user" do
    user_recipe = UserRecipe.new(recipe: recipes(:one))
    assert_not user_recipe.valid?
    assert_includes user_recipe.errors[:user], "must exist"
  end

  test "requires recipe" do
    user_recipe = UserRecipe.new(user: users(:one))
    assert_not user_recipe.valid?
    assert_includes user_recipe.errors[:recipe], "must exist"
  end
end
