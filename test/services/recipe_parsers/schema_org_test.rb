require "test_helper"

class RecipeParsers::SchemaOrgTest < ActiveSupport::TestCase
  setup do
    @parser = RecipeParsers::SchemaOrg.new
  end

  test "parses recipe from JSON-LD with recipeIngredient array" do
    html = build_recipe_html([ "2 cups flour", "1 teaspoon salt", "3 tablespoons butter" ])

    mock_fetch(html) do
      results = @parser.parse("http://example.com/recipe")

      assert_equal 3, results.length

      flour = results.find { |r| r.name.include?("flour") }
      assert_not_nil flour
      assert_equal 2.0, flour.quantity
      assert_equal "cup", flour.unit

      salt = results.find { |r| r.name.include?("salt") }
      assert_not_nil salt
      assert_equal 1.0, salt.quantity
      assert_equal "teaspoon", salt.unit
    end
  end

  test "parses recipe from JSON-LD with @graph structure" do
    html = <<~HTML
      <html>
      <head>
        <script type="application/ld+json">
          {
            "@graph": [
              { "@type": "WebPage", "name": "Blog Post" },
              {
                "@type": "Recipe",
                "name": "Graph Recipe",
                "recipeIngredient": ["1 cup sugar"]
              }
            ]
          }
        </script>
      </head>
      <body></body>
      </html>
    HTML

    mock_fetch(html) do
      results = @parser.parse("http://example.com/recipe")
      assert_equal 1, results.length
      assert_equal "cup", results.first.unit
    end
  end

  test "returns empty array when no JSON-LD found" do
    html = "<html><head></head><body>No structured data</body></html>"

    mock_fetch(html) do
      results = @parser.parse("http://example.com/recipe")
      assert_equal [], results
    end
  end

  test "returns empty array when JSON-LD has no Recipe type" do
    html = <<~HTML
      <html>
      <head>
        <script type="application/ld+json">
          { "@type": "WebPage", "name": "Not a recipe" }
        </script>
      </head>
      <body></body>
      </html>
    HTML

    mock_fetch(html) do
      results = @parser.parse("http://example.com/recipe")
      assert_equal [], results
    end
  end

  test "handles Recipe with array @type" do
    html = <<~HTML
      <html>
      <head>
        <script type="application/ld+json">
          {
            "@type": ["Recipe", "HowTo"],
            "recipeIngredient": ["1 lb chicken breast"]
          }
        </script>
      </head>
      <body></body>
      </html>
    HTML

    mock_fetch(html) do
      results = @parser.parse("http://example.com/recipe")
      assert_equal 1, results.length
      assert_equal "pound", results.first.unit
    end
  end

  test "handles ingredient text with no quantity" do
    html = build_recipe_html([ "salt to taste" ])

    mock_fetch(html) do
      results = @parser.parse("http://example.com/recipe")
      assert_equal 1, results.length
      assert_not_nil results.first.name
    end
  end

private

  def build_recipe_html(ingredients)
    ingredients_json = ingredients.map { |i| "\"#{i}\"" }.join(", ")
    <<~HTML
      <html>
      <head>
        <script type="application/ld+json">
          { "@type": "Recipe", "recipeIngredient": [#{ingredients_json}] }
        </script>
      </head>
      <body></body>
      </html>
    HTML
  end

  def mock_fetch(html, &block)
    @parser.define_singleton_method(:fetch_page) { |_url| html }
    block.call
  end
end
