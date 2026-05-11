class Recipe < ApplicationRecord
  has_many :user_recipes, dependent: :destroy
  has_many :users, through: :user_recipes
  has_many :steps, -> { order(:position) }, dependent: :destroy
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :name, presence: true
end
