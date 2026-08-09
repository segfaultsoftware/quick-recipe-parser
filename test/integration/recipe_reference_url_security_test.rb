require "test_helper"

class RecipeReferenceUrlSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @recipe = recipes(:one)
  end

  test "normalizes reference URLs across create, update, parse, and rendered links" do
    post recipes_url, params: {
      recipe: { name: "Security Regression Recipe", reference_url: " HTTPS://Example.COM/recipe?source=import#ingredients " }
    }

    assert_response :redirect
    recipe = Recipe.order(:created_at).last
    assert_equal "https://example.com/recipe", recipe.reference_url

    patch recipe_url(recipe), params: {
      recipe: { reference_url: " HTTPS://Recipes.Example.COM/updated?source=import#top " }
    }

    assert_response :redirect
    recipe.reload
    assert_equal "https://recipes.example.com/updated", recipe.reference_url

    parser = RecordingParser.new
    with_parser(parser) do
      post parse_recipe_url(recipe), params: {
        url: " HTTPS://Parser.Example.COM/final?source=import#ingredients "
      }, as: :json
    end

    assert_response :success
    recipe.reload
    assert_equal "https://parser.example.com/final", recipe.reference_url
    assert_equal [ recipe.reference_url ], parser.urls

    get recipes_url
    assert_select "a[href='https://parser.example.com/final'][target='_blank'][rel='noopener noreferrer']", count: 1

    get recipe_url(recipe)
    assert_select "a[href='https://parser.example.com/final'][target='_blank'][rel='noopener noreferrer']", count: 1
  end

  test "rejects every prohibited URL class at create, update, and parse boundaries" do
    invalid_urls = {
      unsafe_scheme: "javascript:alert(1)",
      data_scheme: "data:text/html,unsafe",
      malformed: "not a URL",
      missing_host: "https:///recipe",
      localhost: "https://localhost/recipe",
      ipv4: "https://127.0.0.1/recipe",
      ipv6: "https://[::1]/recipe",
      explicit_port: "https://example.com:8443/recipe",
      userinfo: "https://user:password@example.com/recipe",
      unicode_host: "https://例子.测试/recipe",
      punycode_host: "https://xn--fsq.com/recipe",
      single_label_host: "https://example/recipe"
    }

    parser = RecordingParser.new
    with_parser(parser) do
      invalid_urls.each do |label, url|
        recipe = Recipe.new(name: "#{label} recipe", reference_url: url)
        assert_not recipe.save, "#{label} URL should not save"
        assert_match(/(scheme|host|port|userinfo|malformed)/i, recipe.errors[:reference_url].to_sentence)

        original_url = @recipe.reload.reference_url
        assert_not @recipe.update(reference_url: url), "#{label} URL should not update"
        assert_equal original_url, @recipe.reload.reference_url

        post parse_recipe_url(@recipe), params: { url: url }, as: :json
        assert_response :unprocessable_entity, "#{label} URL should be rejected by parse"
        assert_match(/Failed to parse.*(scheme|host|port|userinfo|malformed)/i, JSON.parse(response.body)["error"])
      end
    end

    assert_empty parser.urls
  end

  test "rejects an unsafe redirect target before making a second request" do
    redirect = Net::HTTPFound.new("1.1", "302", "Found")
    redirect["location"] = "https://localhost/unsafe"
    response = Net::HTTPInternalServerError.new("1.1", "500", "Server Error")
    fetched_urls = []

    with_http_responses(->(uri) { fetched_urls << uri.to_s; fetched_urls.length == 1 ? redirect : response }) do
      assert_raises(RecipeReferenceUrlPolicy::InvalidUrlError) do
        RecipeParsers::SchemaOrg.new.parse("https://example.com/recipe")
      end
    end

    assert_equal [ "https://example.com/recipe" ], fetched_urls
  end

  test "renders directly persisted unsafe values as escaped text without hrefs" do
    invalid_url = %(javascript:alert("<script>"))
    @recipe.update_column(:reference_url, invalid_url)

    get recipes_url
    assert_response :success
    assert_includes response.body, ERB::Util.html_escape(invalid_url)
    assert_no_match(/href="[^"]*javascript:/i, response.body)

    get recipe_url(@recipe)
    assert_response :success
    assert_includes response.body, ERB::Util.html_escape(invalid_url)
    assert_no_match(/href="[^"]*javascript:/i, response.body)
  end

private

  class RecordingParser
    attr_reader :urls

    def initialize
      @urls = []
    end

    def parse(url)
      @urls << url
      []
    end
  end

  def with_parser(parser)
    RecipesController.define_method(:build_parser) { parser }
    yield
  ensure
    RecipesController.define_method(:build_parser) { RecipeParsers::SchemaOrg.new }
  end

  def with_http_responses(response_proc)
    original_get_response = Net::HTTP.method(:get_response)
    Net::HTTP.define_singleton_method(:get_response, &response_proc)
    yield
  ensure
    Net::HTTP.define_singleton_method(:get_response, original_get_response) if original_get_response
  end
end
