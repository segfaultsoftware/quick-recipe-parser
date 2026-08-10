require "net/http"
require "json"
require "nokogiri"

module RecipeParsers
  class SchemaOrg < Base
    def parse(url)
      html = fetch_page(RecipeReferenceUrlPolicy.normalize(url))
      doc = Nokogiri::HTML(html)
      recipe_data = extract_recipe_json_ld(doc)

      return [] unless recipe_data

      raw_ingredients = recipe_data["recipeIngredient"] || []
      raw_ingredients.map { |text| parse_ingredient_text(text) }
    end

  private

    def fetch_page(url)
      canonical_url = RecipeReferenceUrlPolicy.normalize(url)
      uri = URI.parse(canonical_url)
      response = Net::HTTP.get_response(uri)

      case response
      when Net::HTTPRedirection
        fetch_page(RecipeReferenceUrlPolicy.normalize(response["location"]))
      when Net::HTTPSuccess
        response.body
      else
        raise "Failed to fetch #{canonical_url}: #{response.code} #{response.message}"
      end
    end

    def extract_recipe_json_ld(doc)
      doc.css('script[type="application/ld+json"]').each do |script|
        data = JSON.parse(script.text)
        result = find_recipe_in_json_ld(data)
        return result if result
      rescue JSON::ParserError
        next
      end

      nil
    end

    def find_recipe_in_json_ld(data)
      case data
      when Hash
        return data if data["@type"] == "Recipe" || Array(data["@type"]).include?("Recipe")

        if data["@graph"].is_a?(Array)
          data["@graph"].each do |item|
            result = find_recipe_in_json_ld(item)
            return result if result
          end
        end
      when Array
        data.each do |item|
          result = find_recipe_in_json_ld(item)
          return result if result
        end
      end

      nil
    end

    def parse_ingredient_text(text)
      text = text.strip

      # Try to match: quantity unit ingredient_name
      match = text.match(/^([\d\s\/\.]+)?\s*([a-zA-Z]+\.?)?\s+(.+)$/)

      if match
        raw_quantity = match[1]&.strip
        raw_unit = match[2]&.strip
        raw_name = match[3]&.strip

        quantity = parse_quantity(raw_quantity)
        unit = map_unit(raw_unit)

        # If the unit didn't map and we have a quantity, the "unit" might be part of the name
        if unit == "count" && raw_unit.present? && raw_quantity.present?
          # Try the first two words as a compound unit (e.g., "fluid ounce")
          raw_name = "#{raw_unit} #{raw_name}"
          unit = "count"
        end

        ParsedIngredient.new(name: raw_name, quantity: quantity, unit: unit)
      else
        ParsedIngredient.new(name: text, quantity: 0, unit: "count")
      end
    end
  end
end
