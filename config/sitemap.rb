# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = ENV.fetch("APP_HOST", "http://localhost:3000")
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create do
  # Static pages
  add root_path, priority: 1.0, changefreq: 'daily'
  add new_user_registration_path, priority: 0.3, changefreq: 'monthly'
  add new_user_session_path, priority: 0.3, changefreq: 'monthly'
  
  # Posts index
  add posts_path, priority: 0.9, changefreq: 'daily'
  
  # Individual posts
  Post.find_each do |post|
    add post_path(post), 
        priority: 0.8, 
        changefreq: 'weekly',
        lastmod: post.updated_at
  end
  
  # Newsletter subscription
  add new_newsletter_subscription_path, priority: 0.5, changefreq: 'monthly'
end
