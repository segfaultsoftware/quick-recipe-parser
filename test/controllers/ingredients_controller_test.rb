require "test_helper"

class IngredientsControllerTest < ActionDispatch::IntegrationTest
  # Search behavior tests

  test "returns matching ingredients" do
    get ingredients_search_url(q: "sa"), as: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_includes results, "salt"
  end

  test "search is case insensitive" do
    get ingredients_search_url(q: "SA"), as: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_includes results, "salt"
  end

  test "returns empty for query shorter than 2 characters" do
    get ingredients_search_url(q: "s"), as: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal [], results
  end

  test "returns empty for blank query" do
    get ingredients_search_url(q: ""), as: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal [], results
  end

  test "returns at most 5 results" do
    6.times { |i| Ingredient.create!(name: "test_item_#{i}") }
    get ingredients_search_url(q: "test_item"), as: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal 5, results.length
  end

  test "returns empty when no matches" do
    get ingredients_search_url(q: "zzzzzzz"), as: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal [], results
  end

  test "matches partial ingredient names" do
    get ingredients_search_url(q: "chick"), as: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_includes results, "chicken breast"
  end
end
