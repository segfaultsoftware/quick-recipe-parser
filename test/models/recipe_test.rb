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

  test "normalizes reference_url when saving" do
    recipe = Recipe.new(
      name: "Normalized Recipe",
      reference_url: " HTTPS://Example.COM/recipe?source=import#ingredients "
    )

    assert recipe.save
    assert_equal "https://example.com/recipe", recipe.reference_url
  end

  test "rejects invalid reference_url on create and update" do
    recipe = Recipe.new(name: "Unsafe Recipe", reference_url: "javascript:alert(1)")

    assert_not recipe.save
    assert_match(/scheme/i, recipe.errors[:reference_url].to_sentence)

    persisted_recipe = recipes(:one)
    original_url = persisted_recipe.reference_url

    assert_not persisted_recipe.update(reference_url: "https://example.com:8443/recipe")
    assert_match(/port/i, persisted_recipe.errors[:reference_url].to_sentence)
    assert_equal original_url, persisted_recipe.reload.reference_url
  end

  test "requires name" do
    recipe = Recipe.new(reference_url: "https://example.com")
    assert_not recipe.valid?
    assert_includes recipe.errors[:name], "can't be blank"
  end

  test "has many users through user_recipes" do
    recipe = recipes(:one)
    assert_includes recipe.users, users(:one)
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
