# Rails Blog - Secure & Production Ready 🔒

A secure, production-ready blog application built with Ruby on Rails 8.1.1 with comprehensive security enhancements, performance optimizations, and n8n newsletter automation.

## ✨ Latest Updates (Feb 2026)

**New Features:**
- 🔍 **SEO Optimizations** - XML sitemaps, meta tags, structured data
- 🚀 **Performance Enhancements** - Image optimization, Gzip compression, CDN support
- ⚡ Redis caching for improved performance
- 📊 View count tracking and counter caches
- 📧 Newsletter subscription system
- 🔗 RESTful API for n8n automation
- 🎯 Background job support for newsletters
- 📈 Database indexes for optimal performance

**See:** [IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md) for full details

## 🔐 Security Features

✅ **Authentication & Authorization** - Devise with confirmable, lockable, and trackable  
✅ **Rate Limiting** - Rack::Attack prevents brute force and spam  
✅ **XSS Protection** - HTML sanitization with whitelist  
✅ **Input Validation** - Comprehensive model validations  
✅ **Account Security** - Lockout after 5 failed login attempts  
✅ **Email Confirmation** - Required before account activation  
✅ **Password Strength** - Minimum 8 characters  
✅ **Audit Logging** - Track sign-ins with IP and timestamps  
✅ **CVE-Free** - All known vulnerabilities patched  
✅ **Performance** - Database indexes and pagination

## � SEO & Performance Features

✅ **XML Sitemap** - Auto-generated, updates daily  
✅ **Meta Tags** - OpenGraph & Twitter Cards for social sharing  
✅ **Structured Data** - Schema.org BlogPosting markup  
✅ **Image Optimization** - libvips processor for fast image processing  
✅ **Gzip Compression** - Reduces bandwidth by 60-80%  
✅ **CDN Ready** - Configurable asset host for CDN  
✅ **Reading Time** - Estimated reading time per post  
✅ **SEO-Friendly URLs** - Clean, descriptive URLs  
✅ **Mobile Optimized** - Responsive design, fast loading

## �🚀 Quick Start

### Prerequisites

- Ruby 3.x
- Rails 8.1.1
- PostgreSQL

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd rails_blog

# Install dependencies
bundle install

# Setup database
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed  # Optional: create sample data

# Start the server
bin/rails server
```

Visit `http://localhost:3000`

### Newsletter & Performance Setup

**For Newsletter Features:**
1. Set API key for n8n integration:
   ```bash
   EDITOR="code --wait" rails credentials:edit
   # Add: api: { key: "your-secure-key" }
   ```
2. See [PERFORMANCE_NEWSLETTER_GUIDE.md](PERFORMANCE_NEWSLETTER_GUIDE.md) for details
3. Configure n8n workflow: [N8N_NEWSLETTER_SETUP.md](N8N_NEWSLETTER_SETUP.md)

**For Performance Features:**
- Redis (optional, for caching): `brew install redis && brew services start redis`
- All database indexes created automatically with migrations

**For SEO Features:**
```bash
# Generate XML sitemap
rails sitemap:refresh

# Sitemap available at: /sitemap.xml
# Updates automatically daily in production
```

### First-Time Setup

**Important:** Email delivery must be configured for user signups to work!

For development, add to your Gemfile:
```ruby
gem "letter_opener", group: :development
```

Then configure in `config/environments/development.rb`:
```ruby
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

## 📚 Documentation

### Core Documentation
- **[IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md)** - ⭐ Complete implementation summary
- **[SECURITY_ENHANCEMENTS.md](SECURITY_ENHANCEMENTS.md)** - Complete security documentation
- **[QUICK_START.md](QUICK_START.md)** - Quick reference guide
- **[BEFORE_AFTER.md](BEFORE_AFTER.md)** - Security improvements comparison

### Newsletter & Performance
- **[N8N_NEWSLETTER_SETUP.md](N8N_NEWSLETTER_SETUP.md)** - 📧 n8n automation guide (detailed)
- **[PERFORMANCE_NEWSLETTER_GUIDE.md](PERFORMANCE_NEWSLETTER_GUIDE.md)** - ⚡ Quick start guide
- **[SEO_PERFORMANCE_GUIDE.md](SEO_PERFORMANCE_GUIDE.md)** - 🔍 SEO & Performance optimization guide
- **[ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)** - 📊 System architecture & data flow
- **[QUICK_COMMANDS.md](QUICK_COMMANDS.md)** - 🔧 Command reference & troubleshooting
- **[n8n-workflow-example.json](n8n-workflow-example.json)** - Ready-to-import n8n workflow

## 🧪 Security Audit

```bash
# Check for vulnerable dependencies
bundle audit check

# Run static security analysis
brakeman -q

# Run tests
bin/rails test
```

**Current Status:**
- ✅ Bundle Audit: No vulnerabilities found
- ✅ Brakeman: No warnings
- ✅ Rails 8.1.1 (latest stable)

## 🎯 Key Features

### User Management
- Email/password authentication
- Email confirmation required
- Account lockout after 5 failed attempts
- Password reset functionality
- Username-based profiles

### Blog Posts
- Create, read, update, delete (CRUD)
- Owner-only edit/delete permissions
- HTML sanitization for safe content
- Pagination (10 posts per page)
- Timestamp tracking
- View count tracking
- Published/draft status

### Newsletter System 📧
- Self-service subscription management
- Secure unsubscribe tokens
- n8n workflow automation support
- RESTful API for external integrations
- Weekly digest generation
- Background job processing

### Performance Optimizations ⚡
- Redis caching for post listings
- Counter cache for user posts
- Database indexes on critical fields
- Eager loading to prevent N+1 queries
- View count tracking without page reload

### Security & Performance
- Rate limiting (60 req/min per IP)
- Login throttling (5 attempts per 20 sec)
- N+1 query prevention
- Database indexes for fast queries
- API key authentication for webhooks

## 🔒 Security Specifications

| Feature | Specification |
|---------|---------------|
| Password Minimum | 8 characters |
| Login Rate Limit | 5 attempts / 20 seconds |
| Post Creation Limit | 10 posts / 5 minutes |
| Account Lockout | 5 failed attempts = 1 hour |
| Email Confirmation | Required for signup |
| Post Title Length | 3-200 characters |
| Post Body Length | 10-10,000 characters |
| Username Length | 3-30 characters |
| Username Format | Alphanumeric + underscore |

## 📦 Dependencies

### Security & Authentication
- `devise` (4.9) - User authentication
- `rack-attack` (6.8.0) - Rate limiting
- `sanitize` (7.0.0) - HTML sanitization

### UI & Pagination
- `kaminari` (1.2.2) - Pagination
- `turbo-rails` - SPA-like navigation
- `stimulus-rails` - JavaScript framework

### Development Tools
- `brakeman` - Security scanner
- `bundler-audit` - CVE checker
- `rubocop-rails-omakase` - Code style

## 🏗️ Architecture

```
app/
├── controllers/
│   ├── application_controller.rb         # Devise configuration
│   ├── posts_controller.rb               # Auth + authorization + caching
│   ├── newsletter_subscriptions_controller.rb  # Subscription management
│   └── api/
│       └── v1/
│           ├── base_controller.rb        # API authentication
│           └── newsletters_controller.rb # n8n webhook endpoints
├── models/
│   ├── post.rb                           # Validations + counter cache + views
│   ├── user.rb                           # Devise + validations
│   └── newsletter_subscription.rb        # Email subscriptions
├── jobs/
│   └── newsletter_digest_job.rb          # Background newsletter prep
├── views/
│   ├── posts/                            # Paginated, sanitized views
│   ├── newsletter_subscriptions/         # Subscribe/unsubscribe pages
│   └── devise/                           # Authentication views
└── helpers/
    └── application_helper.rb             # Sanitization helpers

config/
├── initializers/
│   ├── devise.rb                         # Auth configuration
│   ├── rack_attack.rb                    # Rate limiting rules
│   └── kaminari_config.rb                # Pagination settings
└── routes.rb                             # URL routing + API endpoints

db/
├── migrate/                              # Database migrations
└── schema.rb                             # Current database structure
```

## 🔧 Configuration

### Rate Limiting

Edit `config/initializers/rack_attack.rb` to adjust:
- Request limits per IP
- Login attempt limits
- Post creation limits
- Blocked patterns

### Devise Security

Edit `config/initializers/devise.rb` to adjust:
- Password requirements
- Lockout attempts/duration
- Confirmation timeout
- Session timeout

### Pagination

Edit `config/initializers/kaminari_config.rb` to adjust:
- Posts per page
- Maximum page size

## 🧪 Testing

```bash
# Run all tests
bin/rails test

# Run specific test
bin/rails test test/models/post_test.rb

# Run system tests
bin/rails test:system
```

## 🚀 Deployment

### Prerequisites
1. Configure production email (SMTP/SendGrid/etc)
2. Set environment variables:
   - `SECRET_KEY_BASE`
   - `DATABASE_URL`
   - SMTP credentials
3. Enable SSL (recommended)

### Kamal Deployment

```bash
# Configure in config/deploy.yml
kamal setup
kamal deploy
```

### Environment Variables

```bash
RAILS_ENV=production
SECRET_KEY_BASE=<generate with bin/rails secret>
DATABASE_URL=postgresql://...
MAILER_SENDER=noreply@yourdomain.com
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_USERNAME=apikey
SMTP_PASSWORD=<your-api-key>
```

## 📈 Performance

- Database indexes on frequently queried columns
- Eager loading to prevent N+1 queries
- Pagination limits memory usage
- Rate limiting prevents resource exhaustion

## 🛡️ Threat Model

### Protected Against
✅ SQL Injection (ActiveRecord ORM)  
✅ XSS (HTML sanitization)  
✅ CSRF (Rails built-in protection)  
✅ Brute Force (Rate limiting + lockout)  
✅ Unauthorized Access (Authentication + authorization)  
✅ DoS (Rate limiting + validation limits)  
✅ Session Hijacking (Secure cookies, HTTPS recommended)

### Not Protected Against (Recommendations)
- ⚠️ DDoS at network level (use CDN/WAF)
- ⚠️ Social engineering (user education)
- ⚠️ Zero-day vulnerabilities (keep dependencies updated)

## 🤝 Contributing

1. Review security guidelines in [SECURITY_ENHANCEMENTS.md](SECURITY_ENHANCEMENTS.md)
2. Run security audit before submitting PR
3. Include tests for new features
4. Follow Rails security best practices

## 📄 License

This project is available as open source under the terms of the [MIT License](LICENSE).

## 🔗 Resources

- [Rails Security Guide](https://guides.rubyonrails.org/security.html)
- [Devise Documentation](https://github.com/heartcombo/devise)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Rails 8 Guide](https://guides.rubyonrails.org/)

## 📞 Support

For security issues, please email [security@yourdomain.com](mailto:security@yourdomain.com) instead of creating a public issue.

---

**Last Security Audit:** January 26, 2026  
**Security Status:** ✅ Production Ready
# rails_blog
# rails_blog
