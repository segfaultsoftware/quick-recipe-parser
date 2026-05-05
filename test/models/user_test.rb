require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = users(:one)
    assert user.valid?
  end

  test "requires google_uid" do
    user = User.new(email: "test@example.com", name: "Test")
    assert_not user.valid?
    assert_includes user.errors[:google_uid], "can't be blank"
  end

  test "requires email" do
    user = User.new(google_uid: "uid-123", name: "Test")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "google_uid must be unique" do
    existing = users(:one)
    user = User.new(google_uid: existing.google_uid, email: "new@example.com", name: "New")
    assert_not user.valid?
    assert_includes user.errors[:google_uid], "has already been taken"
  end

  test "email must be unique" do
    existing = users(:one)
    user = User.new(google_uid: "new-uid", email: existing.email, name: "New")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "find_or_create_from_omniauth creates new user" do
    auth = OmniAuth::AuthHash.new(
      uid: "new-google-uid",
      info: { email: "new@example.com", name: "New User", image: "https://example.com/new.jpg" }
    )

    assert_difference "User.count", 1 do
      user = User.find_or_create_from_omniauth(auth)
      assert_equal "new-google-uid", user.google_uid
      assert_equal "new@example.com", user.email
      assert_equal "New User", user.name
      assert_equal "https://example.com/new.jpg", user.avatar_url
    end
  end

  test "find_or_create_from_omniauth finds existing user" do
    existing = users(:one)
    auth = OmniAuth::AuthHash.new(
      uid: existing.google_uid,
      info: { email: existing.email, name: existing.name, image: existing.avatar_url }
    )

    assert_no_difference "User.count" do
      user = User.find_or_create_from_omniauth(auth)
      assert_equal existing.id, user.id
    end
  end
end
