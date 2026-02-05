module ApplicationHelper
  def sanitize_post_content(content)
    Sanitize.fragment(content,
      elements: %w[p br strong em u h1 h2 h3 h4 ul ol li a blockquote code pre],
      attributes: {
        'a' => ['href', 'title'],
        'blockquote' => ['cite']
      },
      protocols: {
        'a' => {'href' => ['http', 'https', 'mailto']}
      }
    )
  end

  # SEO helpers
  def default_meta_tags
    {
      site: 'Rails Blog',
      title: 'Rails Blog - Secure & Production Ready',
      reverse: true,
      separator: '|',
      description: 'A secure, production-ready blog application built with Ruby on Rails featuring comprehensive security, performance optimizations, and newsletter automation.',
      keywords: 'rails, blog, ruby, security, newsletter, seo',
      canonical: request.original_url,
      og: {
        title: :title,
        type: 'website',
        url: request.original_url,
        image: image_url('icon.png'),
        description: :description,
        site_name: 'Rails Blog'
      },
      twitter: {
        card: 'summary_large_image',
        site: '@railsblog',
        title: :title,
        description: :description,
        image: image_url('icon.png')
      }
    }
  end

  def reading_time(content)
    return 0 if content.blank?
    
    words = content.to_plain_text.split.size
    minutes = (words / 200.0).ceil
    "#{minutes} min read"
  end
end
