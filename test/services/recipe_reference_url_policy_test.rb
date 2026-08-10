require "test_helper"

class RecipeReferenceUrlPolicyTest < ActiveSupport::TestCase
  test "returns nil for nil and blank values" do
    assert_nil RecipeReferenceUrlPolicy.normalize(nil)
    assert_nil RecipeReferenceUrlPolicy.normalize("  \t")
  end

  test "normalizes valid http and https URLs without query strings or fragments" do
    assert_equal "http://example.com/recipe", RecipeReferenceUrlPolicy.normalize(
      "http://Example.COM/recipe?source=import#ingredients"
    )
    assert_equal "https://recipes.example.com/recipe", RecipeReferenceUrlPolicy.normalize(
      " https://recipes.example.com/recipe#top "
    )
  end

  test "raises a specific error for an unsafe scheme" do
    error = assert_raises(RecipeReferenceUrlPolicy::InvalidUrlError) do
      RecipeReferenceUrlPolicy.normalize("javascript:alert(1)")
    end

    assert_match(/scheme/i, error.message)
  end

  test "rejects malformed and hostless URLs" do
    assert_invalid_url("not a URL", /malformed/i)
    assert_invalid_url("https:///recipe", /host/i)
    assert_invalid_url("https://[invalid", /malformed/i)
  end

  test "rejects disallowed host forms" do
    assert_invalid_url("https://localhost/recipe", /host/i)
    assert_invalid_url("https://127.0.0.1/recipe", /host/i)
    assert_invalid_url("https://[::1]/recipe", /host/i)
    assert_invalid_url("https://example.com:8443/recipe", /port/i)
    assert_invalid_url("https://user:password@example.com/recipe", /userinfo/i)
    assert_invalid_url("https://例子.测试/recipe", /host/i)
    assert_invalid_url("https://xn--fsq.com/recipe", /host/i)
    assert_invalid_url("https://example/recipe", /host/i)
  end

  test "exposes a predicate without hiding policy errors from normalization" do
    assert RecipeReferenceUrlPolicy.valid?("https://example.com/recipe")
    assert_not RecipeReferenceUrlPolicy.valid?("data:text/html,unsafe")

    assert_raises(RecipeReferenceUrlPolicy::InvalidUrlError) do
      RecipeReferenceUrlPolicy.normalize("data:text/html,unsafe")
    end
  end

  private

  def assert_invalid_url(url, message)
    error = assert_raises(RecipeReferenceUrlPolicy::InvalidUrlError) do
      RecipeReferenceUrlPolicy.normalize(url)
    end

    assert_match(message, error.message)
  end
end
