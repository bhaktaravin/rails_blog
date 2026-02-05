# n8n Newsletter Automation Setup Guide

This guide explains how to set up automated newsletter delivery using n8n workflows with your Rails blog.

## Overview

The newsletter system consists of:
- **Rails API** - Provides subscriber lists and post digests
- **n8n Workflow** - Orchestrates email sending on schedule
- **Newsletter Subscriptions** - Manages subscriber database
- **Background Jobs** - Prepares newsletter content

## Prerequisites

1. **n8n installed** - Self-hosted or n8n Cloud account
2. **Email service** - SMTP, SendGrid, Mailgun, etc.
3. **API Key** - For securing Rails API endpoints

## Step 1: Configure API Key

### Option A: Using Rails Credentials (Recommended)

```bash
EDITOR="code --wait" rails credentials:edit
```

Add:
```yaml
api:
  key: your-secure-random-key-here
```

Generate a secure key:
```bash
rails secret
```

### Option B: Using Environment Variable

```bash
export API_KEY="your-secure-random-key-here"
```

Or add to `.env` file:
```
API_KEY=your-secure-random-key-here
```

## Step 2: Set Host Configuration

Set your production host in environment:

```bash
export HOST="yourblog.com"
```

This ensures correct URLs in the newsletter.

## Step 3: Run Database Migrations

```bash
rails db:migrate
```

This creates:
- `newsletter_subscriptions` table
- `posts.views_count` and `posts.published` columns
- `users.posts_count` column (counter cache)
- Required indexes for performance

## Step 4: API Endpoints

The following endpoints are available for n8n:

### Get Subscribers List
```
GET /api/v1/newsletters/subscribers
Headers:
  X-API-Key: your-api-key
```

Response:
```json
{
  "subscribers": [
    {
      "email": "user@example.com",
      "unsubscribe_url": "https://yourblog.com/newsletters/unsubscribe/TOKEN"
    }
  ],
  "count": 1
}
```

### Get Weekly Digest
```
GET /api/v1/newsletters/digest?days=7&limit=10
Headers:
  X-API-Key: your-api-key
```

Response:
```json
{
  "digest": {
    "period_days": 7,
    "posts": [
      {
        "id": 1,
        "title": "Post Title",
        "excerpt": "First 200 characters...",
        "author": "username",
        "url": "https://yourblog.com/posts/1",
        "views": 42,
        "published_at": "2026-02-04T10:00:00Z"
      }
    ],
    "total_posts": 1
  },
  "generated_at": "2026-02-04T10:00:00Z"
}
```

### Webhook Trigger
```
POST /api/v1/newsletters/webhook
Headers:
  X-API-Key: your-api-key
```

Returns last 7 days of posts.

## Step 5: Create n8n Workflow

### Workflow Overview

1. **Schedule Trigger** - Runs weekly (e.g., every Monday 9 AM)
2. **HTTP Request** - Fetch digest from Rails API
3. **HTTP Request** - Fetch subscribers list
4. **Split In Batches** - Process subscribers in groups
5. **Email Node** - Send newsletter to each subscriber

### Detailed n8n Setup

#### 1. Schedule Trigger Node

```
- Node: Schedule Trigger
- Mode: Cron
- Cron Expression: 0 9 * * 1  (Every Monday at 9 AM)
```

#### 2. Get Newsletter Digest

```
- Node: HTTP Request
- Method: GET
- URL: https://yourblog.com/api/v1/newsletters/digest?days=7&limit=10
- Authentication: Header Auth
  - Name: X-API-Key
  - Value: your-api-key
```

#### 3. Get Subscribers

```
- Node: HTTP Request
- Method: GET
- URL: https://yourblog.com/api/v1/newsletters/subscribers
- Authentication: Header Auth
  - Name: X-API-Key
  - Value: your-api-key
```

#### 4. Process Subscribers

```
- Node: Split In Batches
- Batch Size: 50  (respect email provider limits)
```

#### 5. Build Email Content

```
- Node: Function
- Code:
  const posts = $node["Get Newsletter Digest"].json.digest.posts;
  const subscriber = $json;
  
  let htmlContent = `
    <h1>Weekly Blog Digest</h1>
    <p>Here are the top posts from this week:</p>
  `;
  
  posts.forEach(post => {
    htmlContent += `
      <div style="margin: 20px 0; padding: 15px; border: 1px solid #ddd;">
        <h2><a href="${post.url}">${post.title}</a></h2>
        <p>${post.excerpt}</p>
        <p><small>By ${post.author} | ${post.views} views</small></p>
      </div>
    `;
  });
  
  htmlContent += `
    <hr>
    <p style="font-size: 12px; color: #666;">
      <a href="${subscriber.unsubscribe_url}">Unsubscribe</a>
    </p>
  `;
  
  return {
    to: subscriber.email,
    subject: "Weekly Blog Digest",
    html: htmlContent
  };
```

#### 6. Send Email

```
- Node: Email (or SendGrid, Mailgun, etc.)
- To Email: {{$json.to}}
- Subject: {{$json.subject}}
- Email Format: HTML
- Text: {{$json.html}}
```

## Step 6: Alternative - Webhook Trigger Workflow

For immediate sending when triggered externally:

```
1. Webhook Node
   - Method: POST
   - Path: newsletter-trigger
   
2. HTTP Request - Get Digest
   (same as above)
   
3. HTTP Request - Get Subscribers
   (same as above)
   
4-6. Same email processing as scheduled workflow
```

Trigger URL: `https://your-n8n-instance.com/webhook/newsletter-trigger`

You can trigger from Rails console:
```ruby
# In Rails console or rake task
uri = URI('https://your-n8n-instance.com/webhook/newsletter-trigger')
Net::HTTP.post(uri, '', {'Content-Type' => 'application/json'})
```

## Step 7: Testing

### Test API Endpoints

```bash
# Get subscribers
curl -H "X-API-Key: your-api-key" \
  https://yourblog.com/api/v1/newsletters/subscribers

# Get digest
curl -H "X-API-Key: your-api-key" \
  https://yourblog.com/api/v1/newsletters/digest?days=7
```

### Test Subscription

Visit `/newsletter_subscriptions/new` and subscribe with a test email.

### Test Unsubscribe

Use the unsubscribe URL from API response or email.

## Performance Optimizations Included

### Caching
- Post index caching with Redis
- Cache invalidation on post changes

### Database Optimizations
- Counter cache for `posts_count` on users
- Indexes on:
  - `posts.views_count`
  - `posts.published`
  - `newsletter_subscriptions.status`
  - `newsletter_subscriptions.email`
  - `newsletter_subscriptions.unsubscribe_token`

### Query Optimizations
- Eager loading with `includes(:user)`
- Scoped queries for published posts
- View counting without full page reload

## Subscription Management

### Public Subscribe Page
```
/newsletter_subscriptions/new
```

### Unsubscribe (from email link)
```
/newsletters/unsubscribe/:token
```

### Resubscribe
```
POST /newsletters/resubscribe/:token
```

## Background Jobs

Schedule weekly digest preparation:

```ruby
# config/initializers/recurring.rb or similar
# Using solid_queue or sidekiq

NewsletterDigestJob.perform_later(days: 7)
```

Or use cron job:
```ruby
# lib/tasks/newsletter.rake
namespace :newsletter do
  desc "Prepare weekly newsletter digest"
  task prepare: :environment do
    NewsletterDigestJob.perform_now(days: 7)
  end
end
```

Add to crontab:
```
0 8 * * 1 cd /path/to/app && bin/rails newsletter:prepare
```

## Security Considerations

1. **API Key** - Keep secret, rotate periodically
2. **Rate Limiting** - Rack::Attack already configured
3. **Token Security** - Unsubscribe tokens are 32-byte secure random
4. **HTTPS** - Always use HTTPS in production
5. **Email Validation** - Validates format before saving

## Monitoring

### Check Subscriber Count
```ruby
NewsletterSubscription.active.count
NewsletterSubscription.unsubscribed.count
```

### View Recent Subscriptions
```ruby
NewsletterSubscription.order(created_at: :desc).limit(10)
```

### Check Post Performance
```ruby
Post.popular.limit(10)
Post.where('created_at >= ?', 7.days.ago).order(views_count: :desc)
```

## Troubleshooting

### API Returns 401 Unauthorized
- Check API key is set correctly
- Verify header name is `X-API-Key`
- Check credentials file or environment variable

### No Subscribers in Response
- Verify subscriptions exist: `NewsletterSubscription.active.count`
- Check subscription status is 'active'

### Emails Not Sending
- Verify n8n workflow is active
- Check n8n execution logs
- Test email node configuration
- Verify email service credentials

### Performance Issues
- Run `rails db:migrate` to ensure indexes exist
- Check Redis is running for caching
- Monitor query performance with `rails db:queries`

## Advanced: Custom Email Templates

Create custom newsletter templates in n8n using HTML/CSS:

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; }
    .post { margin: 20px 0; padding: 15px; border-left: 4px solid #007bff; }
    .post h2 { margin-top: 0; }
    .meta { color: #666; font-size: 14px; }
  </style>
</head>
<body>
  <h1>🚀 Weekly Digest</h1>
  <p>Your weekly roundup of the best posts!</p>
  
  <!-- Loop through posts in n8n -->
  <div class="post">
    <h2><a href="{{post.url}}">{{post.title}}</a></h2>
    <p>{{post.excerpt}}</p>
    <div class="meta">By {{post.author}} | {{post.views}} views</div>
  </div>
  
  <hr>
  <p style="text-align: center; color: #999; font-size: 12px;">
    <a href="{{unsubscribe_url}}">Unsubscribe</a> | 
    <a href="https://yourblog.com">Visit Blog</a>
  </p>
</body>
</html>
```

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Email Nodes](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.email/)
- [Rails Action Mailer](https://guides.rubyonrails.org/action_mailer_basics.html)
- [Rack::Attack Configuration](https://github.com/rack/rack-attack)

## Support

For issues or questions:
1. Check n8n execution logs
2. Review Rails logs: `tail -f log/production.log`
3. Test API endpoints manually with curl
4. Verify database migrations ran successfully
