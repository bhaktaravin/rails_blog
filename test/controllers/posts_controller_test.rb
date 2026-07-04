require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner = User.create!(
      email: "owner@example.com",
      username: "owner_user",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
    @other_user = User.create!(
      email: "other@example.com",
      username: "other_user",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
    @post = Post.create!(
      title: "Owner post title",
      body: "This is a sufficiently long post body for testing.",
      user: @owner
    )
  end

  test "index is publicly accessible" do
    get posts_url
    assert_response :success
  end

  test "show is publicly accessible" do
    get post_url(@post)
    assert_response :success
  end

  test "show increments views for non-owner visitors" do
    assert_difference -> { @post.reload.views_count }, 1 do
      get post_url(@post)
    end
  end

  test "show does not increment views for post owner" do
    sign_in @owner

    assert_no_difference -> { @post.reload.views_count } do
      get post_url(@post)
    end
  end

  test "new requires authentication" do
    get new_post_url
    assert_redirected_to new_user_session_url
  end

  test "create requires authentication" do
    assert_no_difference("Post.count") do
      post posts_url, params: {
        post: {
          title: "New post title",
          body: "This is a valid body with enough content."
        }
      }
    end

    assert_redirected_to new_user_session_url
  end

  test "signed-in user can create a post" do
    sign_in @owner

    assert_difference("Post.count", 1) do
      post posts_url, params: {
        post: {
          title: "Created title",
          body: "This is a valid created post body for controller testing."
        }
      }
    end

    assert_redirected_to post_url(Post.last)
    assert_equal @owner, Post.last.user
  end

  test "non-owner cannot edit another users post" do
    sign_in @other_user

    get edit_post_url(@post)
    assert_redirected_to posts_url
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "non-owner cannot update another users post" do
    sign_in @other_user

    patch post_url(@post), params: {
      post: {
        title: "Unauthorized update title"
      }
    }

    assert_redirected_to posts_url
    assert_equal "You are not authorized to perform this action.", flash[:alert]
    assert_not_equal "Unauthorized update title", @post.reload.title
  end

  test "owner can update own post" do
    sign_in @owner

    patch post_url(@post), params: {
      post: {
        title: "Updated by owner"
      }
    }

    assert_redirected_to post_url(@post)
    assert_equal "Updated by owner", @post.reload.title
  end

  test "non-owner cannot destroy another users post" do
    sign_in @other_user

    assert_no_difference("Post.count") do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "owner can destroy own post" do
    sign_in @owner

    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end
end
