module Api
  module V1
    class NewslettersController < BaseController
      # POST /api/v1/newsletters/subscriptions
      # Creates a newsletter subscription for automation clients (e.g. n8n)
      def create_subscription
        subscription = NewsletterSubscription.new(subscription_params)

        if subscription.save
          render json: { message: "Subscribed successfully" }, status: :created
        else
          render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/newsletters/subscribers
      # Returns all active subscribers for n8n to send emails
      def subscribers
        @subscribers = NewsletterSubscription.active
                                            .select(:email, :unsubscribe_token)
                                            .order(created_at: :desc)
        
        render json: {
          subscribers: @subscribers.map { |sub|
            {
              email: sub.email,
              unsubscribe_url: unsubscribe_url(sub.unsubscribe_token)
            }
          },
          count: @subscribers.count
        }
      end
      
      # POST /api/v1/newsletters/webhook
      # Webhook for n8n to trigger newsletter preparation
      def webhook
        posts = Post.published
                   .includes(:user)
                   .where('created_at >= ?', 7.days.ago)
                   .order(created_at: :desc)
                   .limit(10)
        
        render json: {
          posts: posts.map { |post|
            {
              id: post.id,
              title: post.title,
              body: truncate_html(post.body, length: 300),
              author: post.user.username,
              url: post_url(post),
              views: post.views_count,
              published_at: post.created_at.iso8601
            }
          },
          generated_at: Time.current.iso8601
        }
      end
      
      # GET /api/v1/newsletters/digest
      # Get newsletter digest with recent posts
      def digest
        period = params[:days]&.to_i || 7
        
        posts = Post.published
                   .includes(:user)
                   .where('created_at >= ?', period.days.ago)
                   .order(views_count: :desc)
                   .limit(params[:limit]&.to_i || 10)
        
        render json: {
          digest: {
            period_days: period,
            posts: posts.map { |post|
              {
                id: post.id,
                title: post.title,
                excerpt: truncate_html(post.body, length: 200),
                author: post.user.username,
                url: post_url(post),
                views: post.views_count,
                published_at: post.created_at.iso8601
              }
            },
            total_posts: posts.count
          },
          generated_at: Time.current.iso8601
        }
      end
      
      private
      
      def post_url(post)
        Rails.application.routes.url_helpers.post_url(
          post,
          host: ENV['HOST'] || 'localhost:3000',
          protocol: Rails.env.production? ? 'https' : 'http'
        )
      end
      
      def unsubscribe_url(token)
        Rails.application.routes.url_helpers.unsubscribe_newsletter_url(
          token,
          host: ENV['HOST'] || 'localhost:3000',
          protocol: Rails.env.production? ? 'https' : 'http'
        )
      end
      
      def truncate_html(html, length: 200)
        ActionController::Base.helpers.truncate(
          ActionController::Base.helpers.strip_tags(html),
          length: length
        )
      end

      def subscription_params
        params.require(:newsletter_subscription).permit(:email)
      end
    end
  end
end
