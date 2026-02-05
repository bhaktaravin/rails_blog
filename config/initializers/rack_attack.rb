# Rack::Attack configuration for rate limiting and throttling
class Rack::Attack
  # Throttle all requests by IP (60 requests per minute)
  throttle('req/ip', limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Throttle login attempts by email parameter
  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.params['user']&.dig('email')&.to_s&.downcase&.gsub(/\s+/, '')
    end
  end

  # Throttle signup attempts by IP
  throttle('signups/ip', limit: 3, period: 5.minutes) do |req|
    req.ip if req.path == '/users' && req.post?
  end

  # Throttle post creation by IP
  throttle('posts/ip', limit: 10, period: 5.minutes) do |req|
    req.ip if req.path == '/posts' && req.post?
  end

  # Block suspicious requests
  blocklist('block suspicious IPs') do |req|
    # Block if user agent is blank
    req.user_agent.blank?
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    match_data = env['rack.attack.match_data']
    now = match_data[:epoch_time]
    
    headers = {
      'RateLimit-Limit' => match_data[:limit].to_s,
      'RateLimit-Remaining' => '0',
      'RateLimit-Reset' => (now + (match_data[:period] - now % match_data[:period])).to_s,
      'Content-Type' => 'application/json'
    }
    
    body = {
      error: 'Rate limit exceeded. Try again later.',
      retry_after: match_data[:period]
    }.to_json
    
    [429, headers, [body]]
  end
end
