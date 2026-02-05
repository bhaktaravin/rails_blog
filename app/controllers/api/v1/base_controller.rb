module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_key
      
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      
      private
      
      def authenticate_api_key
        api_key = request.headers['X-API-Key']
        expected_key = Rails.application.credentials.dig(:api, :key) || ENV['API_KEY']
        
        unless api_key && ActiveSupport::SecurityUtils.secure_compare(api_key, expected_key.to_s)
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
      
      def not_found
        render json: { error: 'Not found' }, status: :not_found
      end
      
      def unprocessable_entity(exception)
        render json: { error: exception.message }, status: :unprocessable_entity
      end
    end
  end
end
