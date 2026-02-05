class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable
  
  has_many :posts, dependent: :destroy
  has_many :newsletter_subscriptions, dependent: :destroy
  
  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: 'only allows letters, numbers, and underscores' }
  validates :bio, length: { maximum: 500 }, allow_blank: true
  
  before_validation :normalize_username
  
  private
  
  def normalize_username
    self.username = username&.downcase&.strip
  end
end
