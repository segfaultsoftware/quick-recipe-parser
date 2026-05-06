class RecipesController < ApplicationController
  before_action :require_login
  before_action :set_recipe, only: %i[show edit update destroy]

  def index
    @recipes = current_user.recipes.order(:name)
  end

  def show
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params.except(:recipe_ingredients_attributes))

    if @recipe.save
      current_user.recipes << @recipe
      save_recipe_ingredients(@recipe)
      redirect_to @recipe, notice: "Recipe was successfully created."
    else
      rebuild_recipe_ingredients_from_params(@recipe)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params.except(:recipe_ingredients_attributes))
      save_recipe_ingredients(@recipe)
      redirect_to @recipe, notice: "Recipe was successfully updated."
    else
      rebuild_recipe_ingredients_from_params(@recipe)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, notice: "Recipe was successfully deleted."
  end

private

  def set_recipe
    @recipe = current_user.recipes.find(params[:id])
  end

  def recipe_params
    params.expect(recipe: [ :name, :reference_url,
      recipe_ingredients_attributes: [ [ :ingredient_name, :unit_of_measurement, :number_of_units, :_destroy ] ] ])
  end

  def save_recipe_ingredients(recipe)
    recipe.recipe_ingredients.destroy_all

    attrs = recipe_params[:recipe_ingredients_attributes]
    return unless attrs

    attrs.each_value do |ri_attrs|
      next if ri_attrs[:_destroy] == "1"
      next if ri_attrs[:ingredient_name].blank?

      ingredient = Ingredient.find_or_create_by_name(ri_attrs[:ingredient_name])
      recipe.recipe_ingredients.create!(
        ingredient: ingredient,
        unit_of_measurement: ri_attrs[:unit_of_measurement],
        number_of_units: ri_attrs[:number_of_units].presence || 0
      )
    end
  end

  def rebuild_recipe_ingredients_from_params(recipe)
    attrs = params.dig(:recipe, :recipe_ingredients_attributes)
    return unless attrs

    recipe.recipe_ingredients.build(attrs.values.reject { |a| a[:_destroy] == "1" }.map do |ri_attrs|
      next if ri_attrs[:ingredient_name].blank?

      ingredient = Ingredient.find_or_initialize_by(name: ri_attrs[:ingredient_name].strip)
      {
        ingredient: ingredient,
        unit_of_measurement: ri_attrs[:unit_of_measurement],
        number_of_units: ri_attrs[:number_of_units].presence || 0
      }
    end.compact)
  end
end
