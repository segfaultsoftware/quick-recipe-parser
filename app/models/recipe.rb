class Recipe < ApplicationRecord
  before_validation :normalize_reference_url

  has_many :user_recipes, dependent: :destroy
  has_many :users, through: :user_recipes
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :name, presence: true

private

  def normalize_reference_url
    self.reference_url = RecipeReferenceUrlPolicy.normalize(reference_url)
  rescue RecipeReferenceUrlPolicy::InvalidUrlError => e
    errors.add(:reference_url, e.message)
  end
end
