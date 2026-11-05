require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "user_initials with two words" do
    user = User.new(name: "Thiago Henrique", email_address: "thiago@example.com")
    assert_equal "TH", user_initials(user)
  end

  test "user_initials with single word" do
    user = User.new(name: "Thiago", email_address: "thiago@example.com")
    assert_equal "TH", user_initials(user)
  end

  test "user_initials with blank name" do
    user = User.new(name: "", email_address: "blank@example.com")
    assert_equal "?", user_initials(user)
  end

  test "user_avatar renders image when profile_photo is present" do
    user = users(:tree)
    avatar_html = user_avatar(user)
    assert_includes avatar_html, "<img"
    assert_includes avatar_html, user.profile_photo
  end

  test "user_avatar renders initials badge when profile_photo is absent" do
    user = users(:one)
    avatar_html = user_avatar(user)
    assert_not_includes avatar_html, "<img"
    assert_includes avatar_html, "ON"
  end
end
