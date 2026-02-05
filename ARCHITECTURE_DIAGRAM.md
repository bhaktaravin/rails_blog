# Newsletter Automation Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Rails Blog Application                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐    ┌──────────────┐    ┌─────────────────┐  │
│  │   Post       │    │     User     │    │   Newsletter    │  │
│  │              │    │              │    │   Subscription  │  │
│  │ - title      │    │ - email      │    │                 │  │
│  │ - body       │    │ - username   │    │ - email         │  │
│  │ - views_count│◄───│ - posts_count│    │ - status        │  │
│  │ - published  │    │              │    │ - token         │  │
│  └──────────────┘    └──────────────┘    └─────────────────┘  │
│                                                                   │
└───────────────────────────┬───────────────────────────────────┘
                            │
                            │ HTTP API (X-API-Key)
                            │
                    ┌───────▼─────────┐
                    │                  │
                    │   API Endpoints  │
                    │                  │
                    │ GET /subscribers │
                    │ GET /digest      │
                    │ POST /webhook    │
                    │                  │
                    └───────┬─────────┘
                            │
                            │ JSON
                            │
                    ┌───────▼─────────┐
                    │                  │
                    │   n8n Workflow   │
                    │                  │
                    └──────────────────┘
```

## n8n Workflow Steps

```
┌─────────────────────────────────────────────────────────────────┐
│                      n8n Newsletter Workflow                     │
└─────────────────────────────────────────────────────────────────┘

Step 1: Trigger
┌────────────────────┐
│ Schedule Trigger   │  Every Monday at 9 AM
│ Cron: 0 9 * * 1   │
└──────────┬─────────┘
           │
           ▼
Step 2: Fetch Digest
┌────────────────────┐
│  HTTP Request      │  GET /api/v1/newsletters/digest?days=7
│  ╔═══════════════╗ │
│  ║ Headers:      ║ │
│  ║ X-API-Key     ║ │
│  ╚═══════════════╝ │
└──────────┬─────────┘
           │
           │ Returns: { posts: [...] }
           │
           ▼
Step 3: Fetch Subscribers
┌────────────────────┐
│  HTTP Request      │  GET /api/v1/newsletters/subscribers
│  ╔═══════════════╗ │
│  ║ Headers:      ║ │
│  ║ X-API-Key     ║ │
│  ╚═══════════════╝ │
└──────────┬─────────┘
           │
           │ Returns: { subscribers: [{email, unsubscribe_url}...] }
           │
           ▼
Step 4: Process in Batches
┌────────────────────┐
│ Split In Batches   │  Batch size: 50
│                    │  (Respects email limits)
└──────────┬─────────┘
           │
           ▼
Step 5: Build Email
┌────────────────────┐
│ Function Node      │  Combines:
│                    │  - Posts from Step 2
│  ┌──────────────┐ │  - Subscriber from Step 3
│  │ Build HTML   │ │  - Unsubscribe link
│  │ Template     │ │
│  └──────────────┘ │
└──────────┬─────────┘
           │
           │ Output: { to, subject, html }
           │
           ▼
Step 6: Send Email
┌────────────────────┐
│  Email Node        │  Via SMTP/SendGrid/Mailgun
│  ╔═══════════════╗ │
│  ║ To: email     ║ │
│  ║ Subject: ...  ║ │
│  ║ HTML body     ║ │
│  ╚═══════════════╝ │
└──────────┬─────────┘
           │
           │ Loop back to Step 4 for next batch
           │
           ▼
     [Complete]
```

## Data Flow

### 1. Rails API → n8n (Digest)
```json
{
  "digest": {
    "period_days": 7,
    "posts": [
      {
        "id": 1,
        "title": "Building a Secure Blog",
        "excerpt": "Learn how to build...",
        "author": "john_doe",
        "url": "https://blog.com/posts/1",
        "views": 142,
        "published_at": "2026-02-04T10:00:00Z"
      }
    ],
    "total_posts": 1
  }
}
```

### 2. Rails API → n8n (Subscribers)
```json
{
  "subscribers": [
    {
      "email": "user@example.com",
      "unsubscribe_url": "https://blog.com/newsletters/unsubscribe/abc123..."
    }
  ],
  "count": 1
}
```

### 3. n8n → Email Service
```html
<!DOCTYPE html>
<html>
  <head>...</head>
  <body>
    <h1>🚀 Weekly Blog Digest</h1>
    <div class="post">
      <h2><a href="...">Building a Secure Blog</a></h2>
      <p>Learn how to build...</p>
      <div class="meta">By john_doe | 142 views</div>
    </div>
    <p><a href="...">Unsubscribe</a></p>
  </body>
</html>
```

## User Journey

### Subscription Flow
```
User visits blog
     │
     ▼
Clicks "Subscribe to Newsletter"
     │
     ▼
Fills out email form
     │
     ▼
POST /newsletter_subscriptions
     │
     ▼
Database: newsletter_subscriptions
  - email: user@example.com
  - status: active
  - unsubscribe_token: generated
  - subscribed_at: now
     │
     ▼
Confirmation: "Successfully subscribed!"
```

### Unsubscribe Flow
```
User clicks unsubscribe in email
     │
     ▼
GET /newsletters/unsubscribe/:token
     │
     ▼
Database update:
  - status: unsubscribed
  - unsubscribed_at: now
     │
     ▼
Unsubscribed page with resubscribe option
```

### Weekly Newsletter Flow
```
Monday 9:00 AM
     │
     ▼
n8n Schedule Trigger fires
     │
     ▼
Fetch digest (last 7 days posts)
     │
     ▼
Fetch active subscribers
     │
     ▼
For each subscriber (batches of 50):
  │
  ├─ Build HTML email
  ├─ Include unsubscribe link
  └─ Send via email service
     │
     ▼
All subscribers notified
```

## Performance Architecture

### Caching Layer
```
Request: GET /posts
     │
     ▼
Check Rails Cache (Redis)
     │
     ├─ HIT  → Return cached data (fast!)
     │
     └─ MISS → Query database
                    │
                    ▼
               Cache result
                    │
                    ▼
               Return data
```

### View Counting
```
User visits POST show page
     │
     ▼
Check: Is user the post author?
     │
     ├─ YES → Don't increment
     │
     └─ NO  → Increment views_count
               (Direct SQL UPDATE)
```

### Counter Cache
```
User creates new post
     │
     ▼
Rails automatically:
  - INSERT INTO posts
  - UPDATE users SET posts_count = posts_count + 1
     │
     ▼
No need for COUNT(*) queries!
```

## Security Architecture

### API Authentication
```
n8n Request
     │
     ▼
Extract X-API-Key header
     │
     ▼
Secure compare with stored key
     │
     ├─ MATCH    → Process request
     │
     └─ NO MATCH → 401 Unauthorized
```

### Rate Limiting (Rack::Attack)
```
API Request
     │
     ▼
Check request rate per IP
     │
     ├─ Within limit  → Process
     │
     └─ Exceeded      → 429 Too Many Requests
```

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Production Setup                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐    ┌──────────────┐    ┌─────────────────┐  │
│  │   Rails App  │    │    Redis     │    │   PostgreSQL    │  │
│  │   (Puma)     │◄───│   (Cache)    │    │   (Database)    │  │
│  │              │    │              │    │                 │  │
│  │ Port: 3000   │    │ Port: 6379   │    │ Port: 5432      │  │
│  └──────┬───────┘    └──────────────┘    └─────────────────┘  │
│         │                                                        │
└─────────┼────────────────────────────────────────────────────┘
          │
          │ HTTPS API
          │
   ┌──────▼──────┐
   │             │
   │  n8n Cloud  │  Or self-hosted
   │  (Workflow) │
   │             │
   └──────┬──────┘
          │
          │ SMTP
          │
   ┌──────▼──────┐
   │             │
   │ Email       │  SendGrid / Mailgun / SMTP
   │ Service     │
   │             │
   └─────────────┘
```

## Monitoring & Observability

### Key Metrics to Track

1. **Newsletter Metrics**
   - Total subscribers: `NewsletterSubscription.active.count`
   - Unsubscribe rate: `unsubscribed / total`
   - Growth rate: New subscriptions per week

2. **Performance Metrics**
   - Average response time
   - Cache hit rate
   - Database query time
   - Post view counts

3. **API Metrics**
   - Request count per endpoint
   - Error rate (4xx, 5xx)
   - Response time by endpoint

4. **Content Metrics**
   - Most viewed posts
   - Posts per user
   - Publishing frequency

## Technology Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                         Technology Stack                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Backend                                                          │
│  ├─ Ruby 3.x                                                     │
│  ├─ Rails 8.1.1                                                  │
│  └─ PostgreSQL                                                   │
│                                                                   │
│  Caching & Jobs                                                  │
│  ├─ Redis (caching)                                              │
│  ├─ Solid Queue (background jobs)                               │
│  └─ Solid Cache (Rails cache)                                   │
│                                                                   │
│  Authentication                                                  │
│  ├─ Devise                                                       │
│  └─ Rack::Attack (rate limiting)                                │
│                                                                   │
│  Automation                                                      │
│  ├─ n8n (workflow automation)                                    │
│  └─ Custom REST API                                             │
│                                                                   │
│  Frontend                                                        │
│  ├─ Turbo Rails                                                 │
│  ├─ Stimulus.js                                                 │
│  └─ ERB Templates                                               │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

**Legend:**
- `┌─┐` Boxes represent components
- `│` Vertical connections
- `◄─►` Bidirectional data flow
- `▼` Sequential flow
- `├─` Conditional branches
