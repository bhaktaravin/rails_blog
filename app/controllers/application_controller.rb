    before_action :limit_anonymous_posts

    private

    def limit_anonymous_posts
      return if user_signed_in?
      session[:anonymous_posts] ||= 0
      if controller_name == 'posts' && action_name == 'create'
        session[:anonymous_posts] += 1
        if session[:anonymous_posts] > 5
          redirect_to new_user_session_path, alert: 'Please log in to continue posting. You have reached the limit of 5 anonymous posts.'
        end
      end
    end
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :bio, :avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :bio, :avatar])
  end
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
