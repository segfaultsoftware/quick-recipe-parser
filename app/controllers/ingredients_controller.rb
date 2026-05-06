class IngredientsController < ApplicationController
  before_action :require_login

  def search
    query = params[:q].to_s.strip
    if query.length < 2
      render json: []
      return
    end

    ingredients = Ingredient.where("name ILIKE ?", "%#{sanitize_sql_like(query)}%")
                            .order(:name)
                            .limit(5)
                            .pluck(:name)

    render json: ingredients
  end

private

  def sanitize_sql_like(string)
    string.gsub(/[\\%_]/) { |match| "\\#{match}" }
  end
end
