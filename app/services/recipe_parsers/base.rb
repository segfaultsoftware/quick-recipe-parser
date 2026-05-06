module RecipeParsers
  class Base
    ParsedIngredient = Struct.new(:name, :quantity, :unit, keyword_init: true)

    def parse(url)
      raise NotImplementedError, "#{self.class}#parse must be implemented"
    end

  private

    def map_unit(unit_string)
      return "count" if unit_string.blank?

      normalized = unit_string.strip.downcase.singularize

      UNIT_MAPPINGS[normalized] || "count"
    end

    def parse_quantity(quantity_string)
      return 0 if quantity_string.blank?

      # Handle mixed numbers like "1 1/2" (must check before simple fractions)
      if quantity_string.match?(/\d+\s+\d+\/\d+/)
        whole, fraction = quantity_string.split(/\s+/, 2)
        return whole.to_f + parse_quantity(fraction)
      end

      # Handle fractions like "1/2", "3/4"
      if quantity_string.include?("/")
        parts = quantity_string.split("/")
        return 0 unless parts.length == 2

        numerator = parts[0].to_f
        denominator = parts[1].to_f
        return 0 if denominator.zero?

        return numerator / denominator
      end

      quantity_string.to_f
    end

    UNIT_MAPPINGS = {
      # Volume
      "teaspoon" => "teaspoon",
      "tsp" => "teaspoon",
      "tablespoon" => "tablespoon",
      "tbsp" => "tablespoon",
      "fluid ounce" => "fluid_ounce",
      "fl oz" => "fluid_ounce",
      "cup" => "cup",
      "pint" => "pint",
      "pt" => "pint",
      "quart" => "quart",
      "qt" => "quart",
      "gallon" => "gallon",
      "gal" => "gallon",
      "milliliter" => "milliliter",
      "ml" => "milliliter",
      "liter" => "liter",
      "litre" => "liter",
      "l" => "liter",

      # Weight
      "ounce" => "ounce",
      "oz" => "ounce",
      "pound" => "pound",
      "lb" => "pound",
      "gram" => "gram",
      "g" => "gram",
      "kilogram" => "kilogram",
      "kg" => "kilogram",

      # Informal
      "pinch" => "pinch",
      "dash" => "dash",
      "clove" => "clove",
      "slice" => "slice",
      "piece" => "piece",
      "whole" => "whole",
      "can" => "can",
      "bunch" => "bunch",
      "sprig" => "sprig",
      "head" => "head",
      "count" => "count",
      "to taste" => "to_taste"
    }.freeze
  end
end
