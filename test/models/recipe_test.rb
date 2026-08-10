require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "valid recipe with name and reference_url" do
    recipe = recipes(:one)
    assert recipe.valid?
  end

  test "valid recipe without reference_url" do
    recipe = recipes(:no_url)
    assert recipe.valid?
  end

  test "requires name" do
    recipe = Recipe.new(reference_url: "https://example.com")
    assert_not recipe.valid?
    assert_includes recipe.errors[:name], "can't be blank"
  end

  test "does not expose user ownership associations" do
    recipe = recipes(:one)
    assert_not_respond_to recipe, :users
    assert_not_respond_to recipe, :user_recipes
  end

  test "preserves recipe content in the shared collection" do
    recipe = recipes(:one)

    assert_equal "https://example.com/chicken-parm", recipe.reference_url
    assert_equal [ "chicken breast", "pepper", "salt" ], recipe.ingredients.order(:name).pluck(:name)
    assert_equal 3, recipe.recipe_ingredients.count
  end

  test "has many ingredients through recipe_ingredients" do
    recipe = recipes(:one)
    assert_includes recipe.ingredients, ingredients(:salt)
    assert_includes recipe.ingredients, ingredients(:chicken)
  end

  test "destroying recipe destroys recipe_ingredients" do
    recipe = recipes(:one)
    assert_difference "RecipeIngredient.count", -3 do
      recipe.destroy
    end
  end
end
