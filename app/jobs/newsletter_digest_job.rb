class NewsletterDigestJob < ApplicationJob
  queue_as :default

  def perform(days: 7)
    # Prepare newsletter digest data
    posts = Post.published
               .includes(:user)
               .where('created_at >= ?', days.days.ago)
               .order(views_count: :desc)
               .limit(10)
    
    subscribers = NewsletterSubscription.active.pluck(:email)
    
    # Log the digest preparation
    Rails.logger.info "Newsletter digest prepared: #{posts.count} posts, #{subscribers.count} subscribers"
    
    # This job prepares the data
    # n8n will call the API endpoint to fetch this data
    # and send emails using its email node
    {
      posts_count: posts.count,
      subscribers_count: subscribers.count,
      generated_at: Time.current
    }
  end
end
