class NewsletterSubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  
  def new
    @newsletter_subscription = NewsletterSubscription.new
  end
  
  def create
    @newsletter_subscription = NewsletterSubscription.new(subscription_params)
    @newsletter_subscription.user = current_user if user_signed_in?
    
    if @newsletter_subscription.save
      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Successfully subscribed to newsletter!' }
        format.json { render json: { message: 'Subscribed successfully' }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @newsletter_subscription.errors }, status: :unprocessable_entity }
      end
    end
  end
  
  def unsubscribe
    @subscription = NewsletterSubscription.find_by!(unsubscribe_token: params[:token])
    @subscription.unsubscribe!
    
    respond_to do |format|
      format.html { render :unsubscribed }
      format.json { render json: { message: 'Unsubscribed successfully' } }
    end
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
