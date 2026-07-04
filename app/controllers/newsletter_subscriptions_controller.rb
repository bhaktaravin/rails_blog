class NewsletterSubscriptionsController < ApplicationController
  def new
    @newsletter_subscription = NewsletterSubscription.new
  end
  
  def create
    @newsletter_subscription = NewsletterSubscription.new(subscription_params)
    @newsletter_subscription.user = current_user if user_signed_in?
    
    if @newsletter_subscription.save
      redirect_to root_path, notice: 'Successfully subscribed to newsletter!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def unsubscribe
    @subscription = NewsletterSubscription.find_by!(unsubscribe_token: params[:token])
  end

  def perform_unsubscribe
    @subscription = NewsletterSubscription.find_by!(unsubscribe_token: params[:token])
    @subscription.unsubscribe!
    render :unsubscribed
  end
  
  def resubscribe
    @subscription = NewsletterSubscription.find_by!(unsubscribe_token: params[:token])
    @subscription.resubscribe!
    
    redirect_to root_path, notice: 'Successfully resubscribed to newsletter!'
  end
  
  private
  
  def subscription_params
    params.require(:newsletter_subscription).permit(:email)
  end
end
