module RecipesHelper
  def recipe_reference_url_for_link(value)
    RecipeReferenceUrlPolicy.normalize(value)
  rescue RecipeReferenceUrlPolicy::InvalidUrlError
    nil
  end
end
