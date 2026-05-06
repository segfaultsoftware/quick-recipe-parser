require "test_helper"

class RecipeParsers::BaseTest < ActiveSupport::TestCase
  setup do
    @parser = RecipeParsers::Base.new
  end

  test "parse raises NotImplementedError" do
    assert_raises(NotImplementedError) { @parser.parse("http://example.com") }
  end

  test "map_unit maps standard units" do
    assert_equal "teaspoon", @parser.send(:map_unit, "teaspoon")
    assert_equal "teaspoon", @parser.send(:map_unit, "tsp")
    assert_equal "tablespoon", @parser.send(:map_unit, "tablespoon")
    assert_equal "tablespoon", @parser.send(:map_unit, "tbsp")
    assert_equal "cup", @parser.send(:map_unit, "cup")
    assert_equal "cup", @parser.send(:map_unit, "cups")
    assert_equal "ounce", @parser.send(:map_unit, "oz")
    assert_equal "pound", @parser.send(:map_unit, "lb")
    assert_equal "gram", @parser.send(:map_unit, "g")
    assert_equal "kilogram", @parser.send(:map_unit, "kg")
    assert_equal "milliliter", @parser.send(:map_unit, "ml")
    assert_equal "liter", @parser.send(:map_unit, "liter")
  end

  test "map_unit returns count for unknown units" do
    assert_equal "count", @parser.send(:map_unit, "scoops")
    assert_equal "count", @parser.send(:map_unit, "")
    assert_equal "count", @parser.send(:map_unit, nil)
  end

  test "parse_quantity handles integers" do
    assert_equal 3.0, @parser.send(:parse_quantity, "3")
  end

  test "parse_quantity handles decimals" do
    assert_equal 1.5, @parser.send(:parse_quantity, "1.5")
  end

  test "parse_quantity handles fractions" do
    assert_in_delta 0.5, @parser.send(:parse_quantity, "1/2"), 0.01
    assert_in_delta 0.75, @parser.send(:parse_quantity, "3/4"), 0.01
  end

  test "parse_quantity handles mixed numbers" do
    assert_in_delta 1.5, @parser.send(:parse_quantity, "1 1/2"), 0.01
  end

  test "parse_quantity returns 0 for blank" do
    assert_equal 0, @parser.send(:parse_quantity, nil)
    assert_equal 0, @parser.send(:parse_quantity, "")
  end
end
