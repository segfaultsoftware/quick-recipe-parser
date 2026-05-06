class CreateRecipeIngredients < ActiveRecord::Migration[8.1]
  def change
    create_enum :unit_of_measurement, %w[
      teaspoon tablespoon fluid_ounce cup pint quart gallon milliliter liter
      ounce pound gram kilogram
      pinch dash clove slice piece whole can bunch sprig head count to_taste
    ]

    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.enum :unit_of_measurement, enum_type: :unit_of_measurement, null: false
      t.decimal :number_of_units, null: false, default: 0

      t.timestamps
    end
  end
end
