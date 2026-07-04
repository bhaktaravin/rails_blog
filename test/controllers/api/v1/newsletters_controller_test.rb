require "test_helper"

class Api::V1::NewslettersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = "test_api_key_123"
    @original_api_key = ENV["API_KEY"]
    ENV["API_KEY"] = @api_key

    @user = User.create!(
      email: "api_author@example.com",
      username: "api_author",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )

    @post = Post.create!(
      title: "Published API post",
      body: "This post body is long enough to validate and expose in digest API responses.",
      user: @user,
      published: true,
      views_count: 7
    )
  end

  teardown do
    if @original_api_key.nil?
      ENV.delete("API_KEY")
    else
      ENV["API_KEY"] = @original_api_key
    end
  end

  test "should reject requests without api key" do
    get "/api/v1/newsletters/subscribers"
    assert_response :unauthorized
  end

  test "should reject requests with blank api key" do
    get "/api/v1/newsletters/subscribers", headers: { "X-API-Key" => "" }
    assert_response :unauthorized
  end

  test "should reject requests with incorrect api key" do
    get "/api/v1/newsletters/subscribers", headers: { "X-API-Key" => "wrong_key" }
    assert_response :unauthorized
  end

  test "should return subscribers for authorized request" do
    subscription = NewsletterSubscription.create!(
      email: "api_subscriber@example.com",
      status: "active"
    )

    get "/api/v1/newsletters/subscribers", headers: { "X-API-Key" => @api_key }
    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal "api_subscriber@example.com", payload["subscribers"][0]["email"]
    assert_includes payload["subscribers"][0]["unsubscribe_url"], subscription.unsubscribe_token
  end

  test "should create subscription for authorized request" do
    assert_difference("NewsletterSubscription.count", 1) do
      post "/api/v1/newsletters/subscriptions",
           params: {
             newsletter_subscription: {
               email: "created_from_api@example.com"
             }
           },
           headers: { "X-API-Key" => @api_key }
    end

    assert_response :created
  end

  test "should return errors for invalid authorized subscription request" do
    assert_no_difference("NewsletterSubscription.count") do
      post "/api/v1/newsletters/subscriptions",
           params: {
             newsletter_subscription: {
               email: "not_an_email"
             }
           },
           headers: { "X-API-Key" => @api_key }
    end

    assert_response :unprocessable_entity
  end

  test "webhook should return recent published posts for authorized request" do
    post "/api/v1/newsletters/webhook", headers: { "X-API-Key" => @api_key }
    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal 1, payload["posts"].size
    assert_equal @post.id, payload["posts"][0]["id"]
    assert_equal "api_author", payload["posts"][0]["author"]
  end

  test "digest should support days and limit params" do
    second_post = Post.create!(
      title: "Second API post",
      body: "Another sufficiently long body for digest endpoint ordering and limiting.",
      user: @user,
      published: true,
      views_count: 3
    )

    get "/api/v1/newsletters/digest",
        params: { days: 30, limit: 1 },
        headers: { "X-API-Key" => @api_key }

    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal 30, payload.dig("digest", "period_days")
    assert_equal 1, payload.dig("digest", "posts").size
    assert_equal @post.id, payload.dig("digest", "posts", 0, "id")
    assert_not_equal second_post.id, payload.dig("digest", "posts", 0, "id")
  end
end
