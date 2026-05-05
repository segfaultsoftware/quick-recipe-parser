require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "123456",
      info: {
        email: "test@example.com",
        name: "Test User",
        image: "https://example.com/photo.jpg"
      }
    )
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  test "creates user and signs in via google oauth" do
    assert_difference "User.count", 1 do
      get "/auth/google_oauth2/callback"
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Test User", response.body
  end

  test "signs in existing user" do
    User.create!(google_uid: "123456", email: "test@example.com", name: "Test User", avatar_url: "https://example.com/photo.jpg")

    assert_no_difference "User.count" do
      get "/auth/google_oauth2/callback"
    end

    assert_redirected_to root_path
  end

  test "handles authentication failure" do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
    get "/auth/failure?message=invalid_credentials"

    assert_redirected_to root_path
  end

  test "signs out user" do
    get "/auth/google_oauth2/callback"
    assert_redirected_to root_path

    delete sign_out_path
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Sign in with Google", response.body
  end
end
