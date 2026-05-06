require "test_helper"

class RecipeIngredientTest < ActiveSupport::TestCase
  test "valid recipe ingredient" do
    ri = recipe_ingredients(:one_salt)
    assert ri.valid?
  end

  test "requires unit_of_measurement" do
    ri = RecipeIngredient.new(
      recipe: recipes(:one),
      ingredient: ingredients(:salt),
      unit_of_measurement: nil,
      number_of_units: 1
    )
    assert_not ri.valid?
    assert_includes ri.errors[:unit_of_measurement], "can't be blank"
  end

  test "validates unit_of_measurement against enum" do
    ri = RecipeIngredient.new(
      recipe: recipes(:one),
      ingredient: ingredients(:salt),
      unit_of_measurement: "invalid_unit",
      number_of_units: 1
    )
    assert_not ri.valid?
    assert_includes ri.errors[:unit_of_measurement], "is not included in the list"
  end

  test "requires number_of_units" do
    ri = RecipeIngredient.new(
      recipe: recipes(:one),
      ingredient: ingredients(:salt),
      unit_of_measurement: "teaspoon",
      number_of_units: nil
    )
    assert_not ri.valid?
  end

  test "number_of_units must be non-negative" do
    ri = RecipeIngredient.new(
      recipe: recipes(:one),
      ingredient: ingredients(:salt),
      unit_of_measurement: "teaspoon",
      number_of_units: -1
    )
    assert_not ri.valid?
    assert_includes ri.errors[:number_of_units], "must be greater than or equal to 0"
  end

  test "display_text for normal ingredient" do
    ri = recipe_ingredients(:one_salt)
    assert_equal "2 teaspoon salt", ri.display_text
  end

  test "display_text for to_taste ingredient" do
    ri = recipe_ingredients(:one_pepper)
    assert_equal "to taste pepper", ri.display_text
  end

  test "display_text with decimal quantity" do
    ri = recipe_ingredients(:one_chicken)
    assert_equal "1.5 pound chicken breast", ri.display_text
  end

  test "all enum values are valid" do
    RecipeIngredient::UNITS_OF_MEASUREMENT.each do |unit|
      ri = RecipeIngredient.new(
        recipe: recipes(:one),
        ingredient: ingredients(:salt),
        unit_of_measurement: unit,
        number_of_units: 1
      )
      assert ri.valid?, "Expected '#{unit}' to be valid"
    end
  end
end
