require "test_helper"

class NewsletterSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      email: "subscriber_user@example.com",
      username: "subscriber_user",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )
  end

  test "should get new" do
    get new_newsletter_subscription_url
    assert_response :success
  end

  test "should create subscription from html request" do
    assert_difference("NewsletterSubscription.count", 1) do
      post newsletter_subscriptions_url, params: {
        newsletter_subscription: {
          email: "new_subscriber@example.com"
        }
      }
    end

    assert_redirected_to root_url
    assert_equal "Successfully subscribed to newsletter!", flash[:notice]
  end

  test "create succeeds without csrf token when forgery protection is enabled" do
    original_setting = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    assert_no_difference("NewsletterSubscription.count") do
      post newsletter_subscriptions_url, params: {
        newsletter_subscription: {
          email: "csrf_no_token@example.com"
        }
      }
    end

    assert_response :unprocessable_entity
  ensure
    ActionController::Base.allow_forgery_protection = original_setting
  end

  test "should create subscription tied to signed in user" do
    sign_in @user

    assert_difference("NewsletterSubscription.count", 1) do
      post newsletter_subscriptions_url, params: {
        newsletter_subscription: {
          email: "signed_in_subscriber@example.com"
        }
      }
    end

    assert_equal @user, NewsletterSubscription.last.user
  end

  test "should return errors for invalid create" do
    post newsletter_subscriptions_url, params: {
      newsletter_subscription: {
        email: "invalid_email"
      }
    }

    assert_response :unprocessable_entity
  end

  test "unsubscribe should render confirmation without changing status" do
    subscription = NewsletterSubscription.create!(
      email: "unsubscribe_me@example.com",
      status: "active"
    )

    get unsubscribe_newsletter_url(subscription.unsubscribe_token)
    assert_response :success
    assert_equal "active", subscription.reload.status
  end

  test "perform_unsubscribe should mark subscription unsubscribed" do
    subscription = NewsletterSubscription.create!(
      email: "unsubscribe_now@example.com",
      status: "active"
    )

    post perform_unsubscribe_newsletter_url(subscription.unsubscribe_token)
    assert_response :success
    assert_equal "unsubscribed", subscription.reload.status
  end

  test "unsubscribe with invalid token should return not found" do
    get unsubscribe_newsletter_url("invalid-token")
    assert_response :not_found
  end

  test "perform_unsubscribe with invalid token should return not found" do
    post perform_unsubscribe_newsletter_url("invalid-token")
    assert_response :not_found
  end

  test "resubscribe should mark subscription active" do
    subscription = NewsletterSubscription.create!(
      email: "resubscribe_me@example.com",
      status: "unsubscribed",
      unsubscribed_at: Time.current
    )

    post resubscribe_newsletter_url(subscription.unsubscribe_token)
    assert_redirected_to root_url
    assert_equal "Successfully resubscribed to newsletter!", flash[:notice]
    assert_equal "active", subscription.reload.status
    assert_nil subscription.reload.unsubscribed_at
  end

  test "resubscribe with invalid token should return not found" do
    post resubscribe_newsletter_url("invalid-token")
    assert_response :not_found
  end
end
