# Performance & Newsletter Features - Quick Start

## What's New

### Performance Enhancements
✅ Redis caching for post listings
✅ Counter cache for user posts (faster queries)
✅ View count tracking for posts
✅ Published/draft status for posts
✅ Database indexes on critical fields
✅ Eager loading prevents N+1 queries

### Newsletter System
✅ Self-service subscription management
✅ Secure unsubscribe tokens
✅ RESTful API for n8n automation
✅ Weekly digest generation
✅ Background job support

## Quick Setup

### 1. Install Dependencies
```bash
bundle install
```

### 2. Run Migrations
```bash
bin/rails db:migrate
```

### 3. Set API Key for n8n
```bash
# Generate a secure key
rails secret

# Set it in credentials
EDITOR="code --wait" rails credentials:edit
```

Add to credentials:
```yaml
api:
  key: paste-your-generated-secret-here
```

Or use environment variable:
```bash
export API_KEY="your-secure-key"
```

### 4. Configure Host (Production)
```bash
export HOST="yourblog.com"
```

### 5. Optional - Configure Redis
For caching to work optimally, ensure Redis is running:
```bash
# macOS with Homebrew
brew install redis
brew services start redis

# Or use Docker
docker run -d -p 6379:6379 redis
```

## Testing the Features

### Test Newsletter Subscription
```bash
# Start Rails server
bin/rails server

# Visit in browser
open http://localhost:3000/newsletter_subscriptions/new
```

Subscribe with a test email, then check:
```ruby
# In Rails console
bin/rails console
NewsletterSubscription.count
NewsletterSubscription.last
```

### Test API Endpoints

Set your API key:
```bash
export API_KEY="your-api-key-here"
```

Test subscribers endpoint:
```bash
curl -H "X-API-Key: $API_KEY" \
  http://localhost:3000/api/v1/newsletters/subscribers
```

Test digest endpoint:
```bash
curl -H "X-API-Key: $API_KEY" \
  "http://localhost:3000/api/v1/newsletters/digest?days=7&limit=10"
```

### Test Performance Features

Check post views:
```ruby
# In Rails console
post = Post.first
post.views_count  # Should be 0 initially

# Visit the post page in browser
# Then check again
post.reload.views_count  # Should increment
```

Check counter cache:
```ruby
user = User.first
user.posts_count  # Should match actual post count
user.posts.count
```

## Available Routes

### Public Routes
- `GET /newsletter_subscriptions/new` - Subscribe form
- `GET /newsletters/unsubscribe/:token` - Unsubscribe page
- `POST /newsletters/resubscribe/:token` - Resubscribe

### API Routes (Require X-API-Key header)
- `GET /api/v1/newsletters/subscribers` - Get all active subscribers
- `GET /api/v1/newsletters/digest` - Get weekly digest
- `POST /api/v1/newsletters/webhook` - Trigger newsletter preparation

## n8n Integration

See [N8N_NEWSLETTER_SETUP.md](N8N_NEWSLETTER_SETUP.md) for complete guide.

Quick summary:
1. Create n8n workflow with Schedule Trigger (weekly)
2. HTTP Request to fetch digest
3. HTTP Request to fetch subscribers
4. Send emails to each subscriber
5. Include unsubscribe link in each email

## Performance Tips

### View Caching
Posts are automatically cached. Cache is cleared when:
- New post created
- Post updated
- Post deleted

### Counter Cache
User post counts are automatically maintained. To reset:
```ruby
User.find_each { |user| User.reset_counters(user.id, :posts) }
```

### View Counts
Views increment when non-author visits post page. Test:
```ruby
# Visit post as guest or different user
# Views increment automatically
```

## Troubleshooting

### API Returns 401
- Check API key is set in credentials or ENV
- Verify X-API-Key header in request

### Redis Connection Error
- Ensure Redis is running: `redis-cli ping` should return "PONG"
- Check config/cable.yml for Redis URL

### Counter Cache Wrong
Reset counters:
```ruby
bin/rails console
User.find_each { |user| User.reset_counters(user.id, :posts) }
```

### Newsletter Not Saving
Check validation errors:
```ruby
sub = NewsletterSubscription.new(email: "test@example.com")
sub.valid?
sub.errors.full_messages
```

## Next Steps

1. Set up n8n workflow (see N8N_NEWSLETTER_SETUP.md)
2. Add newsletter subscription link to your layout
3. Configure production email service
4. Set up monitoring for API endpoints
5. Schedule regular digest emails

## Example: Add Newsletter Link to Layout

Edit `app/views/layouts/application.html.erb`:

```erb
<!-- In footer or navigation -->
<%= link_to "Subscribe to Newsletter", new_newsletter_subscription_path, class: "newsletter-link" %>
```

## Background Jobs

Schedule weekly digest (optional):
```ruby
# In cron or scheduler
NewsletterDigestJob.perform_later(days: 7)
```

Or create rake task:
```ruby
# lib/tasks/newsletter.rake
namespace :newsletter do
  desc "Send weekly newsletter"
  task send_weekly: :environment do
    # Trigger n8n webhook or prepare digest
    NewsletterDigestJob.perform_now(days: 7)
    puts "Newsletter digest prepared"
  end
end
```

## Performance Metrics

Monitor these in production:
- Average response time for posts#index
- Cache hit rate for Redis
- View count accuracy
- Newsletter subscription rate
- API endpoint usage

Check in Rails console:
```ruby
# Post statistics
Post.sum(:views_count)
Post.average(:views_count)
Post.order(views_count: :desc).limit(10)

# Newsletter statistics
NewsletterSubscription.active.count
NewsletterSubscription.where('created_at >= ?', 30.days.ago).count
```
