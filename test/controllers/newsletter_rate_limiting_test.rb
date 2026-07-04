require "test_helper"

class NewsletterRateLimitingTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = "rate_limit_api_key_123"
    @original_api_key = ENV["API_KEY"]
    ENV["API_KEY"] = @api_key

    @original_allow2ban = Rack::Attack.enabled
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.reset!
  end

  teardown do
    Rack::Attack.reset!
    Rack::Attack.enabled = @original_allow2ban

    if @original_api_key.nil?
      ENV.delete("API_KEY")
    else
      ENV["API_KEY"] = @original_api_key
    end
  end

  test "web newsletter subscription is throttled after 5 requests in 10 minutes" do
    5.times do |i|
      post newsletter_subscriptions_url, params: {
        newsletter_subscription: { email: "web-rate-#{i}@example.com" }
      }
      assert_not_equal 429, response.status
    end

    post newsletter_subscriptions_url, params: {
      newsletter_subscription: { email: "web-rate-final@example.com" }
    }

    assert_response :too_many_requests
  end

  test "api newsletter subscription is throttled after 20 requests in 10 minutes" do
    20.times do |i|
      post "/api/v1/newsletters/subscriptions",
           params: {
             newsletter_subscription: { email: "api-rate-#{i}@example.com" }
           },
           headers: { "X-API-Key" => @api_key }
      assert_not_equal 429, response.status
    end

    post "/api/v1/newsletters/subscriptions",
         params: {
           newsletter_subscription: { email: "api-rate-final@example.com" }
         },
         headers: { "X-API-Key" => @api_key }

    assert_response :too_many_requests
  end
end
