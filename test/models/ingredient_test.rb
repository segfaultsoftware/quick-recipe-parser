require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  test "valid ingredient with name" do
    ingredient = ingredients(:salt)
    assert ingredient.valid?
  end

  test "requires name" do
    ingredient = Ingredient.new(name: nil)
    assert_not ingredient.valid?
    assert_includes ingredient.errors[:name], "can't be blank"
  end

  test "name must be unique case-insensitively" do
    Ingredient.create!(name: "sugar")
    duplicate = Ingredient.new(name: "Sugar")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "find_or_create_by_name finds existing" do
    existing = ingredients(:salt)
    found = Ingredient.find_or_create_by_name("salt")
    assert_equal existing, found
  end

  test "find_or_create_by_name creates new" do
    assert_difference "Ingredient.count", 1 do
      Ingredient.find_or_create_by_name("oregano")
    end
  end

  test "find_or_create_by_name strips whitespace" do
    existing = ingredients(:salt)
    found = Ingredient.find_or_create_by_name("  salt  ")
    assert_equal existing, found
  end

  test "has many recipes through recipe_ingredients" do
    ingredient = ingredients(:salt)
    assert_includes ingredient.recipes, recipes(:one)
  end
end
