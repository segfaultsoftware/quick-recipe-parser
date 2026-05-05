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

  test "has many users through user_recipes" do
    recipe = recipes(:one)
    assert_includes recipe.users, users(:one)
  end
end
