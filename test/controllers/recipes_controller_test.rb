require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @recipe = recipes(:one)

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: @user.google_uid,
      info: { email: @user.email, name: @user.name, image: @user.avatar_url }
    )
    get "/auth/google_oauth2/callback"
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  # Auth gating tests

  test "redirects unauthenticated user from index" do
    delete sign_out_path
    get recipes_url
    assert_redirected_to root_path
  end

  test "redirects unauthenticated user from new" do
    delete sign_out_path
    get new_recipe_url
    assert_redirected_to root_path
  end

  # Index tests

  test "shows every recipe in the shared collection" do
    get recipes_url
    assert_response :success
    assert_match @recipe.name, response.body
    assert_match recipes(:two).name, response.body
    assert_select "a", text: recipes(:no_url).name
  end

  test "renders invalid persisted reference URLs as escaped text on index" do
    invalid_url = %(javascript:alert("<script>"))
    @recipe.update_column(:reference_url, invalid_url)

    get recipes_url

    assert_response :success
    assert_includes response.body, ERB::Util.html_escape(invalid_url)
    assert_no_match(/href="[^"]*javascript:/i, response.body)
  end

  test "renders persisted reference URLs canonically on index" do
    @recipe.update_column(:reference_url, "https://example.com/chicken-parm?source=import#ingredients")

    get recipes_url

    assert_response :success
    assert_select "a[href='https://example.com/chicken-parm'][target='_blank'][rel='noopener noreferrer']" do |links|
      assert_equal "Reference", links.first.text
    end
    assert_no_match(/href="[^"]*source=import/, response.body)
  end

  # Show tests

  test "shows recipe detail" do
    get recipe_url(@recipe)
    assert_response :success
    assert_match @recipe.name, response.body
    assert_match @recipe.reference_url, response.body
  end

  test "renders invalid persisted reference URLs as escaped text on show" do
    invalid_url = %(javascript:alert("<script>"))
    @recipe.update_column(:reference_url, invalid_url)

    get recipe_url(@recipe)

    assert_response :success
    assert_includes response.body, ERB::Util.html_escape(invalid_url)
    assert_no_match(/href="[^"]*javascript:/i, response.body)
  end

  test "omits blank persisted reference URLs on show" do
    @recipe.update_column(:reference_url, "")

    get recipe_url(@recipe)

    assert_response :success
    assert_no_match(/Reference:/, response.body)
  end

  test "renders persisted reference URLs canonically on show" do
    @recipe.update_column(:reference_url, "https://example.com/chicken-parm?source=import#ingredients")

    get recipe_url(@recipe)

    assert_response :success
    assert_select "a[href='https://example.com/chicken-parm'][target='_blank'][rel='noopener noreferrer']" do |links|
      assert_equal "https://example.com/chicken-parm", links.first.text
    end
    assert_no_match(/href="[^"]*source=import/, response.body)
  end

  test "shows recipe ingredients on detail page" do
    get recipe_url(@recipe)
    assert_response :success
    assert_match "2 teaspoon salt", response.body
    assert_match "to taste pepper", response.body
    assert_match "1.5 pound chicken breast", response.body
  end

  test "shows any recipe in the shared collection" do
    get recipe_url(recipes(:two))
    assert_response :success
  end

  # Create tests

  test "renders new recipe form" do
    get new_recipe_url
    assert_response :success
  end

  test "creates recipe with valid params" do
    assert_difference "Recipe.count", 1 do
      post recipes_url, params: { recipe: { name: "New Recipe", reference_url: "https://example.com/new" } }
    end

    recipe = Recipe.last
    assert_redirected_to recipe_url(recipe)
    assert_equal "New Recipe", recipe.name
  end

  test "creates recipe without reference_url" do
    assert_difference "Recipe.count", 1 do
      post recipes_url, params: { recipe: { name: "Simple Recipe" } }
    end

    recipe = Recipe.last
    assert_redirected_to recipe_url(recipe)
    assert_nil recipe.reference_url
  end

  test "creates recipe with ingredients" do
    assert_difference [ "Recipe.count", "RecipeIngredient.count" ], 1 do
      post recipes_url, params: { recipe: {
        name: "Salted Pasta",
        recipe_ingredients_attributes: {
          "0" => { ingredient_name: "salt", unit_of_measurement: "teaspoon", number_of_units: "2" }
        }
      } }
    end

    recipe = Recipe.last
    assert_redirected_to recipe_url(recipe)
    assert_equal 1, recipe.recipe_ingredients.count
    ri = recipe.recipe_ingredients.first
    assert_equal "salt", ri.ingredient.name
    assert_equal "teaspoon", ri.unit_of_measurement
    assert_equal 2, ri.number_of_units
  end

  test "creates recipe with to_taste ingredient" do
    post recipes_url, params: { recipe: {
      name: "Seasoned Dish",
      recipe_ingredients_attributes: {
        "0" => { ingredient_name: "pepper", unit_of_measurement: "to_taste", number_of_units: "0" }
      }
    } }

    recipe = Recipe.last
    ri = recipe.recipe_ingredients.first
    assert_equal "to_taste", ri.unit_of_measurement
    assert_equal 0, ri.number_of_units
  end

  test "reuses existing ingredient by name" do
    assert_no_difference "Ingredient.count" do
      post recipes_url, params: { recipe: {
        name: "Another Salty Dish",
        recipe_ingredients_attributes: {
          "0" => { ingredient_name: "salt", unit_of_measurement: "tablespoon", number_of_units: "1" }
        }
      } }
    end
  end

  test "fails to create recipe without name" do
    assert_no_difference "Recipe.count" do
      post recipes_url, params: { recipe: { name: "", reference_url: "https://example.com" } }
    end

    assert_response :unprocessable_entity
  end

  # Update tests

  test "renders edit form" do
    get edit_recipe_url(@recipe)
    assert_response :success
  end

  test "updates recipe" do
    patch recipe_url(@recipe), params: { recipe: { name: "Updated Name" } }
    assert_redirected_to recipe_url(@recipe)
    @recipe.reload
    assert_equal "Updated Name", @recipe.name
  end

  test "updates recipe ingredients replaces all" do
    patch recipe_url(@recipe), params: { recipe: {
      name: @recipe.name,
      recipe_ingredients_attributes: {
        "0" => { ingredient_name: "garlic", unit_of_measurement: "clove", number_of_units: "4" }
      }
    } }

    assert_redirected_to recipe_url(@recipe)
    @recipe.reload
    assert_equal 1, @recipe.recipe_ingredients.count
    assert_equal "garlic", @recipe.recipe_ingredients.first.ingredient.name
  end

  test "fails to update recipe with blank name" do
    patch recipe_url(@recipe), params: { recipe: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "updates any recipe in the shared collection" do
    patch recipe_url(recipes(:two)), params: { recipe: { name: "Hacked" } }
    assert_redirected_to recipe_url(recipes(:two))
    assert_equal "Hacked", recipes(:two).reload.name
  end

  # Delete tests

  test "deletes recipe" do
    assert_difference "Recipe.count", -1 do
      delete recipe_url(@recipe)
    end

    assert_redirected_to recipes_url
  end

  test "deletes any recipe in the shared collection" do
    assert_difference "Recipe.count", -1 do
      delete recipe_url(recipes(:two))
    end

    assert_redirected_to recipes_url
  end

  # Parse tests

  test "parse requires authentication" do
    delete sign_out_path
    post parse_recipe_url(@recipe)
    assert_redirected_to root_path
  end

  test "parse returns error when no url provided and recipe has no reference_url" do
    recipe_no_url = recipes(:no_url)

    post parse_recipe_url(recipe_no_url), as: :json
    assert_response :unprocessable_entity

    data = JSON.parse(response.body)
    assert_match(/No reference URL/, data["error"])
  end

  test "parse uses url from params and saves it to the recipe" do
    recipe_no_url = recipes(:no_url)

    parsed = [
      RecipeParsers::Base::ParsedIngredient.new(name: "sugar", quantity: 1.0, unit: "cup")
    ]

    parser = FakeParser.new(parsed)
    RecipesController.define_method(:build_parser) { parser }

    post parse_recipe_url(recipe_no_url), params: { url: " HTTPS://Example.COM/new-recipe?source=import#ingredients " }, as: :json
    assert_response :success

    recipe_no_url.reload
    assert_equal "https://example.com/new-recipe", recipe_no_url.reference_url
    assert_equal recipe_no_url.reference_url, parser.url
  ensure
    RecipesController.define_method(:build_parser) { RecipeParsers::SchemaOrg.new }
  end

  test "parse rejects invalid url before invoking the parser" do
    recipe_no_url = recipes(:no_url)
    current_user.recipes << recipe_no_url unless current_user.recipes.include?(recipe_no_url)
    parser = FakeParser.new([])
    RecipesController.define_method(:build_parser) { parser }

    post parse_recipe_url(recipe_no_url), params: { url: "javascript:alert(1)" }, as: :json
    assert_response :unprocessable_entity

    data = JSON.parse(response.body)
    assert_match(/scheme/i, data["error"])
    assert_nil parser.url
    assert_nil recipe_no_url.reload.reference_url
  ensure
    RecipesController.define_method(:build_parser) { RecipeParsers::SchemaOrg.new }
  end

  test "parse saves ingredients from parsed URL" do
    parsed = [
      RecipeParsers::Base::ParsedIngredient.new(name: "flour", quantity: 2.0, unit: "cup"),
      RecipeParsers::Base::ParsedIngredient.new(name: "baking soda", quantity: 1.0, unit: "teaspoon")
    ]

    RecipesController.define_method(:build_parser) { FakeParser.new(parsed) }

    post parse_recipe_url(@recipe), as: :json
    assert_response :success

    data = JSON.parse(response.body)
    assert_equal 2, data["count"]
    assert data["ingredients"].any? { |i| i["name"] == "flour" }
  ensure
    RecipesController.define_method(:build_parser) { RecipeParsers::SchemaOrg.new }
  end

  test "parse replaces existing ingredients" do
    assert @recipe.recipe_ingredients.count > 0

    parsed = [
      RecipeParsers::Base::ParsedIngredient.new(name: "sugar", quantity: 3.0, unit: "cup")
    ]

    RecipesController.define_method(:build_parser) { FakeParser.new(parsed) }

    post parse_recipe_url(@recipe), as: :json
    assert_response :success

    @recipe.reload
    assert_equal 1, @recipe.recipe_ingredients.count
    assert_equal "sugar", @recipe.recipe_ingredients.first.ingredient.name
  ensure
    RecipesController.define_method(:build_parser) { RecipeParsers::SchemaOrg.new }
  end

  test "parse handles errors gracefully" do
    RecipesController.define_method(:build_parser) { ErrorParser.new("Connection refused") }

    post parse_recipe_url(@recipe), as: :json
    assert_response :unprocessable_entity

    data = JSON.parse(response.body)
    assert_match(/Failed to parse/, data["error"])
  ensure
    RecipesController.define_method(:build_parser) { RecipeParsers::SchemaOrg.new }
  end

  test "parse returns empty when no ingredients found" do
    RecipesController.define_method(:build_parser) { FakeParser.new([]) }

    post parse_recipe_url(@recipe), as: :json
    assert_response :success

    data = JSON.parse(response.body)
    assert_equal 0, data["count"]
  ensure
    RecipesController.define_method(:build_parser) { RecipeParsers::SchemaOrg.new }
  end

private

  class FakeParser
    def initialize(result)
      @result = result
    end

    attr_reader :url

    def parse(url)
      @url = url
      @result
    end
  end

  class ErrorParser
    def initialize(message)
      @message = message
    end

    def parse(_url)
      raise StandardError, @message
    end
  end
end
