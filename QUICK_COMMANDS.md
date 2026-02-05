# Quick Reference Commands

## Setup Commands

### Initial Setup
```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:create
bin/rails db:migrate

# Start Redis (for caching)
brew install redis
brew services start redis

# Start server
bin/rails server
```

### Set API Key
```bash
# Generate secure key
rails secret

# Option 1: Use credentials (recommended)
EDITOR="code --wait" rails credentials:edit
# Add: api: { key: "your-key-here" }

# Option 2: Use environment variable
export API_KEY="your-secure-key"
```

## Testing Commands

### Test Newsletter Subscription
```bash
# Start server
bin/rails server

# Open subscribe page
open http://localhost:3000/newsletter_subscriptions/new
```

### Test API Endpoints
```bash
# Set your API key
export API_KEY="your-api-key"

# Test subscribers endpoint
curl -H "X-API-Key: $API_KEY" \
  http://localhost:3000/api/v1/newsletters/subscribers

# Test digest endpoint (last 7 days)
curl -H "X-API-Key: $API_KEY" \
  "http://localhost:3000/api/v1/newsletters/digest?days=7&limit=10"

# Test digest with different parameters
curl -H "X-API-Key: $API_KEY" \
  "http://localhost:3000/api/v1/newsletters/digest?days=30&limit=5"

# Test webhook endpoint
curl -X POST \
  -H "X-API-Key: $API_KEY" \
  http://localhost:3000/api/v1/newsletters/webhook
```

### Test with Pretty JSON
```bash
# Install jq (if not installed)
brew install jq

# Pretty print responses
curl -H "X-API-Key: $API_KEY" \
  http://localhost:3000/api/v1/newsletters/subscribers | jq

curl -H "X-API-Key: $API_KEY" \
  "http://localhost:3000/api/v1/newsletters/digest?days=7" | jq
```

## Rails Console Commands

### Newsletter Management
```ruby
# Open console
bin/rails console

# Create a test subscription
sub = NewsletterSubscription.create!(email: "test@example.com")

# View all subscriptions
NewsletterSubscription.all

# Count active subscribers
NewsletterSubscription.active.count

# Find by email
NewsletterSubscription.find_by(email: "test@example.com")

# Unsubscribe
sub = NewsletterSubscription.find_by(email: "test@example.com")
sub.unsubscribe!

# Resubscribe
sub.resubscribe!

# Get unsubscribe URL
sub = NewsletterSubscription.first
puts sub.unsubscribe_token

# View recent subscriptions
NewsletterSubscription.order(created_at: :desc).limit(10)

# Statistics
NewsletterSubscription.group(:status).count
NewsletterSubscription.where('created_at >= ?', 30.days.ago).count
```

### Post Performance
```ruby
# View counts
post = Post.first
post.views_count

# Increment views manually
post.increment_views
post.reload.views_count

# Most viewed posts
Post.order(views_count: :desc).limit(10)

# Recent posts
Post.where('created_at >= ?', 7.days.ago).order(created_at: :desc)

# Published posts
Post.published.count
Post.where(published: false).count

# Total views across all posts
Post.sum(:views_count)
Post.average(:views_count)

# Posts by user with counter cache
user = User.first
user.posts_count
user.posts.count  # Should match
```

### Counter Cache Management
```ruby
# Check counter cache
user = User.first
puts "Counter cache: #{user.posts_count}"
puts "Actual count: #{user.posts.count}"

# Reset counter cache for one user
User.reset_counters(user.id, :posts)

# Reset for all users
User.find_each { |u| User.reset_counters(u.id, :posts) }

# Update all counter caches (if they're out of sync)
User.find_each do |user|
  User.update_counters user.id, posts_count: user.posts.count - user.posts_count
end
```

### Newsletter Digest
```ruby
# Get posts for digest (last 7 days)
posts = Post.published
           .includes(:user)
           .where('created_at >= ?', 7.days.ago)
           .order(views_count: :desc)
           .limit(10)

# View digest data
posts.map { |p| { title: p.title, views: p.views_count, author: p.user.username } }

# Run newsletter job
NewsletterDigestJob.perform_now(days: 7)
```

## Database Commands

### Migrations
```bash
# Run migrations
bin/rails db:migrate

# Rollback last migration
bin/rails db:rollback

# Check migration status
bin/rails db:migrate:status

# Reset database (CAUTION: Deletes all data)
bin/rails db:reset
```

### Console Database Queries
```ruby
# Check schema version
ActiveRecord::Base.connection.migration_context.current_version

# List tables
ActiveRecord::Base.connection.tables

# Check indexes
ActiveRecord::Base.connection.indexes(:posts)
ActiveRecord::Base.connection.indexes(:newsletter_subscriptions)

# Check column info
Post.column_names
NewsletterSubscription.column_names

# Raw SQL query
ActiveRecord::Base.connection.execute("SELECT * FROM newsletter_subscriptions LIMIT 5")
```

## Cache Management

### Redis Commands
```bash
# Connect to Redis CLI
redis-cli

# In Redis CLI:
# Check if Redis is running
PING  # Should return PONG

# View all keys
KEYS *

# Get a specific key
GET "posts:index"

# Delete all keys (clear cache)
FLUSHALL

# View cache stats
INFO stats

# Exit Redis CLI
exit
```

### Rails Cache Commands
```ruby
# In Rails console
# Read cache
Rails.cache.read(["posts", "index"])

# Write cache
Rails.cache.write(["test"], "value", expires_in: 1.hour)

# Delete specific cache
Rails.cache.delete(["posts", "index"])

# Clear all cache
Rails.cache.clear

# Check if key exists
Rails.cache.exist?(["posts", "index"])

# Fetch with fallback
Rails.cache.fetch(["posts", "index"], expires_in: 1.hour) do
  Post.includes(:user).recent.limit(10).to_a
end
```

## Route Commands

### View Routes
```bash
# All routes
bin/rails routes

# Filter routes
bin/rails routes | grep newsletter
bin/rails routes | grep api

# Show specific controller routes
bin/rails routes -c newsletter_subscriptions
bin/rails routes -c api/v1/newsletters

# Show routes in expanded format
bin/rails routes --expanded
```

## Testing & Quality Commands

### Run Tests
```bash
# All tests
bin/rails test

# Specific test file
bin/rails test test/models/newsletter_subscription_test.rb

# Specific test
bin/rails test test/models/newsletter_subscription_test.rb:10

# System tests
bin/rails test:system
```

### Security Checks
```bash
# Check for vulnerable gems
bundle audit check

# Update vulnerability database
bundle audit update

# Run Brakeman security scanner
brakeman -q

# Run with all options
brakeman -A -q
```

### Code Quality
```bash
# Run RuboCop
rubocop

# Auto-fix issues
rubocop -a

# Check specific files
rubocop app/models/newsletter_subscription.rb
```

## Production Commands

### Environment Setup
```bash
# Set production environment
export RAILS_ENV=production

# Set host
export HOST="yourblog.com"

# Set API key
export API_KEY="your-production-key"

# Set Redis URL
export REDIS_URL="redis://localhost:6379/0"
```

### Asset Compilation
```bash
# Precompile assets
bin/rails assets:precompile

# Clean old assets
bin/rails assets:clean
```

### Database in Production
```bash
# Run migrations
RAILS_ENV=production bin/rails db:migrate

# Check migration status
RAILS_ENV=production bin/rails db:migrate:status
```

## Monitoring Commands

### Check Application Health
```bash
# Health check endpoint
curl http://localhost:3000/health
curl http://localhost:3000/up

# Check if server is running
ps aux | grep puma

# Check Redis
redis-cli ping

# Check PostgreSQL
psql -l
```

### View Logs
```bash
# Development logs
tail -f log/development.log

# Production logs
tail -f log/production.log

# Follow logs with search
tail -f log/development.log | grep Newsletter

# View last 100 lines
tail -n 100 log/development.log

# View logs with date filter
grep "2026-02-04" log/development.log
```

### Process Management
```bash
# Find Rails server process
ps aux | grep rails

# Kill Rails server
killall ruby

# Start in background
bin/rails server -d

# Stop background server
cat tmp/pids/server.pid | xargs kill
```

## Backup & Restore

### Database Backup
```bash
# Backup database
pg_dump -U postgres rails_blog_development > backup.sql

# Backup with custom format
pg_dump -Fc -U postgres rails_blog_development > backup.dump

# Restore database
psql -U postgres rails_blog_development < backup.sql

# Restore custom format
pg_restore -U postgres -d rails_blog_development backup.dump
```

### Export/Import Newsletter Subscribers
```ruby
# In Rails console

# Export to CSV
require 'csv'
CSV.open('subscribers.csv', 'w') do |csv|
  csv << ['Email', 'Status', 'Subscribed At']
  NewsletterSubscription.find_each do |sub|
    csv << [sub.email, sub.status, sub.subscribed_at]
  end
end

# Import from CSV
require 'csv'
CSV.foreach('subscribers.csv', headers: true) do |row|
  NewsletterSubscription.create!(
    email: row['Email'],
    status: row['Status'] || 'active',
    subscribed_at: row['Subscribed At'] || Time.current
  )
end
```

## Troubleshooting Commands

### Check Dependencies
```bash
# List installed gems
bundle list

# Check specific gem version
bundle info redis

# Update specific gem
bundle update redis

# Check for outdated gems
bundle outdated
```

### Check Configuration
```ruby
# In Rails console

# Check credentials
Rails.application.credentials.api

# Check environment
Rails.env

# Check Redis connection
Redis.new.ping  # Should return "PONG"

# Check database connection
ActiveRecord::Base.connection.active?

# Check loaded configuration
Rails.configuration.cache_store
```

### Reset Everything
```bash
# CAUTION: This will delete all data!

# Stop server
killall ruby

# Drop and recreate database
bin/rails db:drop
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

# Clear cache
redis-cli FLUSHALL

# Restart server
bin/rails server
```

## n8n Commands

### Import Workflow
```bash
# Copy example workflow to n8n data directory
cp n8n-workflow-example.json ~/n8n/workflows/

# Or import via n8n UI:
# 1. Open n8n
# 2. Click "Import from File"
# 3. Select n8n-workflow-example.json
```

### Test n8n Webhook
```bash
# Trigger webhook (if you set one up)
curl -X POST https://your-n8n.com/webhook/newsletter-trigger

# Test with data
curl -X POST https://your-n8n.com/webhook/newsletter-trigger \
  -H "Content-Type: application/json" \
  -d '{"trigger": "manual"}'
```

## Performance Profiling

### Benchmark in Console
```ruby
# In Rails console
require 'benchmark'

# Benchmark query with counter cache
Benchmark.measure do
  1000.times { User.first.posts_count }
end

# vs without counter cache
Benchmark.measure do
  1000.times { User.first.posts.count }
end

# Benchmark cached vs uncached
Rails.cache.clear
Benchmark.measure do
  Post.includes(:user).recent.limit(10).to_a
end

# Second call (should be faster with cache)
Benchmark.measure do
  Post.includes(:user).recent.limit(10).to_a
end
```

## Useful Aliases (Optional)

Add to `~/.zshrc` or `~/.bashrc`:

```bash
# Rails shortcuts
alias rc='bin/rails console'
alias rs='bin/rails server'
alias rt='bin/rails test'
alias rr='bin/rails routes'
alias rdm='bin/rails db:migrate'

# Newsletter specific
alias nsubs='curl -H "X-API-Key: $API_KEY" http://localhost:3000/api/v1/newsletters/subscribers | jq'
alias ndigest='curl -H "X-API-Key: $API_KEY" "http://localhost:3000/api/v1/newsletters/digest?days=7" | jq'

# Logs
alias rl='tail -f log/development.log'
alias rlt='tail -f log/test.log'

# Cache
alias rclear='bin/rails console -e "Rails.cache.clear"'
```

## Quick Diagnostic Script

Create `bin/diagnose`:

```bash
#!/bin/bash

echo "=== Rails Blog Diagnostics ==="
echo ""

echo "✓ Checking Ruby version..."
ruby -v

echo "✓ Checking Rails version..."
bin/rails -v

echo "✓ Checking database connection..."
bin/rails runner "puts ActiveRecord::Base.connection.active? ? 'Connected' : 'Failed'"

echo "✓ Checking Redis..."
redis-cli ping

echo "✓ Checking migrations..."
bin/rails db:migrate:status | tail -5

echo "✓ Newsletter subscribers count..."
bin/rails runner "puts NewsletterSubscription.active.count"

echo "✓ Total post views..."
bin/rails runner "puts Post.sum(:views_count)"

echo ""
echo "=== Diagnostics Complete ==="
```

Make executable:
```bash
chmod +x bin/diagnose
./bin/diagnose
```

---

**Pro Tip:** Keep this file handy for quick reference during development and production operations!
