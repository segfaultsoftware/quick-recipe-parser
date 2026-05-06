class RecipeIngredient < ApplicationRecord
  UNITS_OF_MEASUREMENT = %w[
    teaspoon tablespoon fluid_ounce cup pint quart gallon milliliter liter
    ounce pound gram kilogram
    pinch dash clove slice piece whole can bunch sprig head count to_taste
  ].freeze

  belongs_to :recipe
  belongs_to :ingredient

  validates :unit_of_measurement, presence: true, inclusion: { in: UNITS_OF_MEASUREMENT }
  validates :number_of_units, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def display_text
    if unit_of_measurement == "to_taste"
      "to taste #{ingredient.name}"
    else
      unit_label = unit_of_measurement.humanize.downcase
      "#{number_of_units_display} #{unit_label} #{ingredient.name}"
    end
  end

private

  def number_of_units_display
    number_of_units == number_of_units.to_i ? number_of_units.to_i.to_s : number_of_units.to_s
  end
end
