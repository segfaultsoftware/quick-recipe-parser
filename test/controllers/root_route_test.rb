require "test_helper"

class RootRouteTest < ActionDispatch::IntegrationTest
  test "opens the shared recipe collection without authentication" do
    get root_url
    assert_response :success
    assert_match recipes(:one).name, response.body
    assert_no_match(/Sign in|Sign out|Google/i, response.body)
  end

  test "preserves Rails CSRF protection in the shared layout" do
    layout = Rails.root.join("app/views/layouts/application.html.erb").read
    assert_includes layout, "csrf_meta_tags"
  end

  test "does not expose authentication routes" do
    get "/auth/google_oauth2/callback"
    assert_response :not_found

    delete "/sign_out"
    assert_response :not_found
  end
end
