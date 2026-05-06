class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :ingredients, "LOWER(name)", unique: true, name: "index_ingredients_on_lower_name"
  end
end
