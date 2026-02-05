class NewsletterSubscription < ApplicationRecord
  belongs_to :user, optional: true
  
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true, inclusion: { in: %w[active unsubscribed] }
  validates :unsubscribe_token, presence: true, uniqueness: true
  
  before_validation :generate_unsubscribe_token, on: :create
  before_validation :set_subscribed_at, on: :create
  
  scope :active, -> { where(status: 'active') }
  scope :unsubscribed, -> { where(status: 'unsubscribed') }
  
  def unsubscribe!
    update(status: 'unsubscribed', unsubscribed_at: Time.current)
  end
  
  def resubscribe!
    update(status: 'active', unsubscribed_at: nil)
  end
  
  private
  
  def generate_unsubscribe_token
    self.unsubscribe_token ||= SecureRandom.urlsafe_base64(32)
  end
  
  def set_subscribed_at
    self.subscribed_at ||= Time.current
  end
end
