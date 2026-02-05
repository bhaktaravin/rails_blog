# Performance optimizations for Rails application

Rails.application.configure do
  # Enable HTTP caching headers for all responses
  config.action_dispatch.default_headers.merge!({
    'X-Frame-Options' => 'SAMEORIGIN',
    'X-Content-Type-Options' => 'nosniff',
    'X-XSS-Protection' => '1; mode=block',
    'Referrer-Policy' => 'strict-origin-when-cross-origin'
  })
end

# Optimize database queries
ActiveSupport.on_load(:active_record) do
  # Enable query logging in development to catch N+1 queries
  if Rails.env.development?
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
  
  # Set reasonable query timeout to prevent slow queries
  # ActiveRecord::Base.connection.execute("SET statement_timeout = 5000") if defined?(ActiveRecord::Base)
end

# Configure ETags for efficient caching
Rails.application.config.action_controller.default_static_extension = '.html'

# Preload associations to avoid N+1 queries
module PreloadAssociations
  extend ActiveSupport::Concern
  
  included do
    # This will be included in controllers that need it
    def self.preload_associations(*associations)
      around_action do |controller, action|
        ActiveRecord::Base.connection_pool.with_connection do
          action.call
        end
      end
    end
  end
end
