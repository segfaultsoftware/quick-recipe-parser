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

  test "shows only current user recipes" do
    get recipes_url
    assert_response :success
    assert_match @recipe.name, response.body
    assert_no_match recipes(:two).name, response.body
  end

  # Show tests

  test "shows recipe detail" do
    get recipe_url(@recipe)
    assert_response :success
    assert_match @recipe.name, response.body
    assert_match @recipe.reference_url, response.body
  end

  test "cannot view another user recipe" do
    get recipe_url(recipes(:two))
    assert_response :not_found
  end

  # Create tests

  test "renders new recipe form" do
    get new_recipe_url
    assert_response :success
  end

  test "creates recipe with valid params" do
    assert_difference [ "Recipe.count", "UserRecipe.count" ], 1 do
      post recipes_url, params: { recipe: { name: "New Recipe", reference_url: "https://example.com/new" } }
    end

    recipe = Recipe.last
    assert_redirected_to recipe_url(recipe)
    assert_equal "New Recipe", recipe.name
    assert_includes @user.recipes, recipe
  end

  test "creates recipe without reference_url" do
    assert_difference "Recipe.count", 1 do
      post recipes_url, params: { recipe: { name: "Simple Recipe" } }
    end

    recipe = Recipe.last
    assert_redirected_to recipe_url(recipe)
    assert_nil recipe.reference_url
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

  test "fails to update recipe with blank name" do
    patch recipe_url(@recipe), params: { recipe: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "cannot update another user recipe" do
    patch recipe_url(recipes(:two)), params: { recipe: { name: "Hacked" } }
    assert_response :not_found
  end

  # Delete tests

  test "deletes recipe" do
    assert_difference "Recipe.count", -1 do
      delete recipe_url(@recipe)
    end

    assert_redirected_to recipes_url
  end

  test "cannot delete another user recipe" do
    delete recipe_url(recipes(:two))
    assert_response :not_found
  end
end
